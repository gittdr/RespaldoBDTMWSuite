SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE function [dbo].[TMWSSRS_fcn_ssrsrb_FreightLines]    
 (@stp_number as int)    
     
returns varchar(max)    
    
as    
    
begin    
    
--set @stp_number = 7674    
    
declare @TotalVolume as int    
declare @msg as varchar(max)     
set @msg = ''    
    
    
declare @FreightItems table    
 (fgt_description varchar(200),    
  fgt_volume int,    
  fLength int)    
      
    
insert into @FreightItems    
select     
 fgt.fgt_description,    
 fgt.fgt_volume,    
 LEN(fgt.fgt_description)    
from freightdetail fgt    
where fgt.stp_number = @stp_number    
order by fgt_sequence    
    
    
select         
 @msg = @msg + rtrim(fgt_description) + REPLICATE(' ', 15-fLength) + ltrim(rtrim(str(fgt_volume))) + char(10) + char(13)     
from @FreightItems    
    
    
    
set @TotalVolume =     
 (select         
  SUM(fgt.fgt_volume)     
 from freightdetail fgt    
 where fgt.stp_number = @stp_number)    
     
set @msg = @msg + char(10) + char(13) +  'Total:         '  + ltrim(rtrim(str(@TotalVolume))) + char(10) + char(13)     
     
return @msg    
    
end 
GO
GRANT EXECUTE ON  [dbo].[TMWSSRS_fcn_ssrsrb_FreightLines] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWSSRS_fcn_ssrsrb_FreightLines] TO [public]
GO
