#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Thrift::API::HBaseClient2' ) || print "Bail out!\n";
}

diag( "Testing Thrift::API::HBaseClient2 $Thrift::API::HBaseClient2::VERSION, Perl $], $^X" );
