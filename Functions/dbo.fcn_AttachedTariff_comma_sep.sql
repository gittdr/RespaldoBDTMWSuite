SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fcn_AttachedTariff_comma_sep]
( 
 @tar_number int
 
)

returns varchar(2000)

as

begin
--declare @num varchar(12)
declare @rs varchar(2000)
declare @cnt int

select @rs = ','
select @cnt = 0

while 1=1
begin

 select @cnt = min(taa_seq)
 from tariffaccessorial ta
   inner join tariffkey accTar on accTar.trk_number =  ta.trk_number
   inner join tariffheader accTarH on accTarH.tar_number = accTar.tar_number
 where ta.tar_number = @tar_number
    and taa_seq > @cnt

 if @cnt is NULL BREAK


  select @rs = @rs + cast(acctarh.tar_number as varchar(6)) + ' - ' +  acctarh.tar_description + ','
  from tariffaccessorial ta
    inner join tariffkey accTar on accTar.trk_number =  ta.trk_number
    inner join tariffheader accTarH on accTarH.tar_number = accTar.tar_number
  where ta.tar_number = @tar_number
     and taa_seq = @cnt
end

 
 return substring(LEFT(@rs, len(@rs)-1), 2, len(@rs))
 

end
GO
