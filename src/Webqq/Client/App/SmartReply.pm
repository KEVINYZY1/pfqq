package Webqq::Client::App::SmartReply;
use Exporter 'import';
use JSON;
use Encode;
use Webqq::Client::Util qw(truncate);
@EXPORT=qw(SmartReply);
my $API = 'http://www.tuling123.com/openapi/api';
#my $API = 'http://www.xiaodoubi.com/bot/api.php?chat=';
sub SmartReply{
    my $msg = shift;
    my $client = shift;
    return unless $msg->{content} =~/\@小灰 /;
    my $input = $msg->{content};
    my $userid = $msg->from_qq;
    my $from_nick = $msg->from_nick;
    $input=~s/\@[^ ]+ |\[[^\[\]]+\]\x01|\[[^\[\]]+\]//g;
    my @query_string = (
        "key"       =>  "4c53b48522ac4efdfe5dfb4f6149ae51",
        "userid"    =>  $userid,
        "info"      =>  $input,
    );
    my @query_string_pairs;
    push @query_string_pairs , shift(@query_string) . "=" . shift(@query_string) while(@query_string);
    $client->{asyn_ua}->get($API . "?" . join("&",@query_string_pairs),(),sub{
        my $res =shift;
        if($client->{debug}){
            print "GET " . $API . "?" . join("&",@query_string_pairs),"\n";
            print $res->as_string,"\n";
        }
        my $reply;
        my $data = JSON->new->utf8->decode($res->content);
        return if $data->{code}=~/^4000[1-7]$/;
        if($data->{code} == 100000){
            $reply = encode("utf8",$data->{text});
        } 
        elsif($data->{code}== 200000){
            $reply = encode("utf8","$data->{text}\n$data->{url}");
        }
        $reply  = "\@$from_nick " . $reply  if rand(100)>20;
        $reply = truncate($reply);
        $client->reply_message($msg,$reply) if $reply;
    });
     
}
1;
