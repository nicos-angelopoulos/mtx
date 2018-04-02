%
% @author nicos angelopoulos
% @version  0.1 2015/12/02
%
mtx_option_header_attach( true, Rows, Hdr, [Hdr|Rows] ).
mtx_option_header_attach( false, Rows, _Hdr, Rows ).
