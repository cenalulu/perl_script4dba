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

sub read_config {
    my $conf_file=shift;
    my $log = shift;
    my %conf_hash;

    unless( $log ){
        $log = init_log();
    }
    open( my $fh, "<$conf_file" )
        or $log->error("Cannot open config file: $conf_file");
    while( <$fh> ){
        my $line=$_;
        if($line=~ /^\#/){
            $log->debug("Line #$. is a comment line skip");
        }elsif($_ =~ /(\S+?)\s*=\s*(.*)$/){
            my ($k,$v)=($1,$2);
            $conf_hash{$1}=$2;
            $log->debug("Line #$. parse success: $k => $v");
        }else{
            $log->warning("Line #$. wrong format: $line");
        }
    }
    close( $fh );
    return %conf_hash;

}
1;
