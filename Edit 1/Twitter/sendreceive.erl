-module(sendreceive).

-export([tweetBackToserver/1,getTweetFromUser/1,hashTagTweetMap/1,breaktweet/5,receiveTweetFromUser/0,sendTweetToAllSubscribers/4]).



getTweetFromUser(UserTweetMap)->
    receive
        {UserName,Tweet,Pid,RemoteNodePid}->
            TweetLst=maps:find(UserName,UserTweetMap),
            if
              TweetLst==error->
                    Pid ! {"User Not present in Server Database",RemoteNodePid},
                    getTweetFromUser(UserTweetMap); 
                true ->
                    {ok,Tweets}=TweetLst,
                    io:format("~s~n",[Tweet]),
                    io:format("~p~n",[Tweets]),
                    Tweets1=lists:append(Tweets,[Tweet]),
                    io:format("~p~n",[Tweets1]),
                    NewUserTweetMap=maps:put(UserName,Tweets1,UserTweetMap), 
                    Pid ! {"Tweet Posted",RemoteNodePid},  
                    TweetSplitList=string:split(Tweet," ",all),
                    io:format("~p~n",[TweetSplitList]),
                    breaktweet(TweetSplitList,1,Tweet,UserName,"#"),
                    breaktweet(TweetSplitList,1,Tweet,UserName,"@"),
                    subscribeToUser ! {UserName,self()},
                    receive
                        {Subscribers}->
                          io:format("Subscribers are ~p~n",[Subscribers]),
                          spawn(sendreceive,sendTweetToAllSubscribers,[Subscribers,1,Tweet,UserName])
                    end,                  
                    getTweetFromUser(NewUserTweetMap)  
            end;
         {UserName}->
            NewUserTweetMap=maps:put(UserName,[],UserTweetMap),
            getTweetFromUser(NewUserTweetMap);
         {UserName,Pid,RemoteNodePid}->
           TweetLst=maps:find(UserName,UserTweetMap),
            if
              TweetLst==error->
                    Pid ! {[],RemoteNodePid};
                true ->
                    {ok,Tweets}=TweetLst,
                    io:format("length= ~p~n",[length(Tweets)]),
                    Pid ! {Tweets,RemoteNodePid}
            end,
            getTweetFromUser(UserTweetMap)
    end. 


hashTagTweetMap(HashTagTweetMap)->
   receive
    {HashTag,Tweet,UserName,addnewhashTag}->
        io:format("~s~n",[Tweet]),
      TweetLst=maps:find(HashTag,HashTagTweetMap),
        if
          TweetLst==error->
                NewHashTagTweetMap=maps:put(HashTag,[{Tweet,UserName}],HashTagTweetMap),
                hashTagTweetMap(NewHashTagTweetMap); 
            true ->
                {ok,Tweets}=TweetLst,
                io:format("~p~n",[Tweets]),
                Tweets1=lists:append(Tweets,[{Tweet,UserName}]),
                io:format("~p~n",[Tweets1]),
                NewHashTagTweetMap=maps:put(HashTag,Tweets1,HashTagTweetMap),
                % io:format("~p",NewUserTweetMap),                
                hashTagTweetMap(NewHashTagTweetMap)  
        end;
     {HashTag,Pid,RemoteNodePid}->
       TweetLst=maps:find(HashTag,HashTagTweetMap),
        if
          TweetLst==error->
                Pid ! {[],RemoteNodePid};
            true ->
                {ok,Tweets}=TweetLst,
                io:format("~p~n",[Tweets]),
                Pid ! {Tweets,RemoteNodePid}
        end,
        hashTagTweetMap(HashTagTweetMap)
    end.
sendTweetToAllSubscribers(Subscribers,Srno,Tweet,UserName)->
 if
    Srno>length(Subscribers)->
            ok;
    true->
        {Username1,_}=lists:nth(Srno,Subscribers),
        % io:format("~p~n",[Pid]),
        userProcessIdMap!{Username1,Tweet},
        sendTweetToAllSubscribers(Subscribers,Srno+1,Tweet,UserName)
 end.       

receiveTweetFromUser()->
    receive
     {Msg,UserName}->
        CurrentMessage=UserName++" : "++Msg,
        io:format("~s~n",[CurrentMessage]),
        receiveTweetFromUser()
    end.







breaktweet(SplitTweet,Srno,Tweet,UserName,Tag)->
  if
    Srno==length(SplitTweet)+1 ->
      ok;
    true ->
      CurrentString=string:find(lists:nth(Srno,SplitTweet),Tag,trailing),
      io:format("~s~n",[CurrentString]),
      if
        CurrentString==nomatch ->
          ok;
        true ->
          hashTagMap ! {CurrentString,Tweet,UserName,addnewhashTag}
      end,
      breaktweet(SplitTweet,Srno+1,Tweet,UserName,Tag)
  end.




tweetBackToserver(Tweet)->
  try persistent_term:get("LoggedIn")
  catch
    error:X ->
      io:format("~p~n",[X])
  end,
  LoggedIn=persistent_term:get("LoggedIn"),
  if
    LoggedIn==true->
      RmtSvrId=persistent_term:get("ServerId"),
      RmtSvrId!{persistent_term:get("UserName"),Tweet,self(),tweet},
      receive
        {Registered}->
          io:format("~s~n",[Registered])
      end;
    true->
      io:format("You should sign in to send tweets Call main:signin_register() to complete signin~n")
  end.