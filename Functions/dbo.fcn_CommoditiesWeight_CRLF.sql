SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fcn_CommoditiesWeight_CRLF]
( 
 @ord_hdrnumber int,@stp_number int
 )

returns varchar(200)

as

begin
--declare @num varchar(12)
declare @rs varchar(200)
declare @cnt int

select @rs = ''
select @cnt = 0

while 1=1
begin
 select @cnt = min(fgt_sequence)
 from freightdetail f with (nolock)
 join stops s with (nolock) on s.stp_number = f.stp_number
 where  ord_hdrnumber = @ord_hdrnumber
  and fgt_sequence > @cnt
  and F.stp_number = @stp_number
 
 if @cnt is NULL BREAK

  select @rs = @rs + convert(varchar(50),fgt_weight)+ ' '+ fgt_weightunit + char(10) + char(13)
  from freightdetail F with (nolock)
  join stops s with (nolock) on s.stp_number = f.stp_number
  where  ord_hdrnumber = @ord_hdrnumber
  and fgt_sequence = @cnt
  and F.stp_number = @stp_number
 end

 
 return @rs
 

end
GO
