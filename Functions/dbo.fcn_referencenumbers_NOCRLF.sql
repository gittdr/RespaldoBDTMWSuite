SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fcn_referencenumbers_NOCRLF]
( 
 @tbl_key int,
 @tbl varchar(18)
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
 select @cnt = min(ref_sequence)
 from referencenumber
 where ref_tablekey = @tbl_key 
  and ref_table = @tbl
  and ref_sequence > @cnt
 if @cnt is NULL BREAK

  select @rs = @rs + ref_type +': '+ref_number + ', '
  from referencenumber 
  where ref_tablekey = @tbl_key 
  and ref_table = @tbl
  and ref_sequence = @cnt
end

 
 return @rs
 

end
GO
