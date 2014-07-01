#! /usr/bin/perl


package BasicUtil;

use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

sub init_log {
    my $log_output = shift;
    my $log_level = shift;
    my $log;
    $log_level = 'info' unless ($log_level);

    $log = Log::Dispatch->new(
            callbacks => sub{
                my %args = @_;
                my $msg = $args{message};
                $msg = '' unless ($msg);
                chomp $msg;
                if( $args{level} eq "error" ){
                    my ($ln, $script) = ( caller(4) )[2,1];
                    $script =~ s/.*:://;
                    return sprintf( "[%s][%s, ln%d] %s\n", $args{level}, $script, $ln, $msg);
                }
                return sprintf( "[%s] %s\n", $args{level}, $msg);
            }
            );
    unless($log_output){
        $log->add( 
            Log::Dispatch::Screen->new(
                name => 'screen',
                min_level => $log_level,
                mode => 'append',
                callbacks => sub{
                        my %p = @_;
                        sprintf "%s - %s", scalar(localtime), $p{message};
                },
            )
        );
    }else{
        $log->add(
            Log::Dispatch::File->new(
                name => 'file',
                filename => $log_output,
                min_level => $log_level,
                mode => 'append',
                close_after_write => 1,
                callbacks => sub{
                        my %p = @_;
                        sprintf "%s - %s", scalar(localtime), $p{message};
                },
            )
        );
    }
    return $log;
}

1;
