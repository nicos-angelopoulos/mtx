%
% @author nicos angelopoulos
% @version  0.1 2015/12/02
%
mtx_option_header_remove( true, [Hdr|Rows], Hdr, Rows ).
mtx_option_header_remove( false, Rows, false, Rows ).
