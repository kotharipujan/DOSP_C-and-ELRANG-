-module(main).

-export([signin_register/0,startengine/0,signinsystem/0,tweet/0,userlist/0,follow/0,signout/0,hashtag/1,retweet/1]).

signin_register()->
    io:format("~s~n",["Welcome TO WORLD'S BEST TWITTER BY PUJAN MUSK AND ELON PORWAL"]),
    {ok,[LogIn]}=io:fread("To Log in, Press S!!! To Register, Press R","~ts"),
    if
        (LogIn=="S")->
            registerfunc:signInUser();
        true->
            registerfunc:registerUser()
    end.
tweet()->
    Tweet1=io:get_line("Enter Your Tweet "),
    Tweet=lists:nth(1,string:tokens(Tweet1,"\n")),
    try sendreceive:tweetBackToserver(Tweet)
    catch 
    error:_ -> 
      io:format("User is not signed in~n")
    end.   

follow()->
    UserName1=io:get_line("Enter User You want to follow to"),
    UserName=lists:nth(1,string:tokens(UserName1,"\n")),
    register:subscribeToUser(UserName).
signout()->
    register:signOutUser().

userlist()->

    spawn(register,userlist,[]).

startengine()->
    Twt1 = [{"Elon","musk"}],
    Twt2=[{"Rahulia",["I am the greatest"]}],
    Twt3=[{"I","Want internship for summer 2023 "}],
    Twt5=[{"Pujank",[]}],
    Twt4=[{"DOSP","LOL"}],
    Plt1 = maps:from_list(Twt1),
    Plt2 = maps:from_list(Twt2),
    Plt3= maps:from_list(Twt3),
    Plt4=maps:from_list(Twt4),
    Plt5=maps:from_list(Twt5),
    register(userregister,spawn(list_to_atom("centralserver@DESKTOP-CPC7PAK"),register,recieveMessage,[Plt1])),
    register(receiveTweet,spawn(list_to_atom("centralserver@DESKTOP-CPC7PAK"),sendreceive,getTweetFromUser,[Plt2])),
    register(hashTagMap,spawn(list_to_atom("centralserver@DESKTOP-CPC7PAK"),sendreceive,hashTagTweetMap,[Plt3])),
    register(subscribeToUser,spawn(list_to_atom("centralserver@DESKTOP-CPC7PAK"),register,userSubscriberMap,[Plt4])),
    register(userProcessIdMap,spawn(list_to_atom("centralserver@DESKTOP-CPC7PAK"),register,userProcessIdMap,[Plt5])).

signinsystem()->
    receive
    % for LogIn
        {UserName,Password,Pid}->
            userregister ! {UserName,Password,self(),Pid};
    % for registerfuncation
        {UserName,Pwd,Email,Pid,registerfunc}->
            userregister ! {UserName,Pwd,Email,self(),Pid};
        {UserName,Tweet,Pid,tweet}->
            receiveTweet !{UserName,Tweet,self(),Pid};
        {UserName,Pid}->
            if
                Pid==signOut->
                    [UserName1,RemoteNodePid]=UserName,
                    userProcessIdMap!{UserName1,RemoteNodePid,self(),randomShitAgain};
                true->
                    receiveTweet !{UserName,self(),Pid}
            end;
        {Pid}->
            userregister ! {self(),Pid,"FOR BLUETICK PAY US 8$"};
        {UserName,CurrentUserName,Pid,RcvPid}->
            subscribeToUser ! {UserName,CurrentUserName,RcvPid,self(),Pid}
    end,
    receive
        {Msg,Pid1}->
            Pid1 ! {Msg},
            signinsystem()
    end.


hashtag(Hashname)->
    io:format("~s~n",[Hashname]),
io:format("~s~n",["I love doing #DOSP project"]).

retweet(Name)->
    io:format("~s~n",[Name]),
    io:format("~s~n",["Tweet has been reTweeted"]).