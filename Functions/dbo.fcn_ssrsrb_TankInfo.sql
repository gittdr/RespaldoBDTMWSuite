SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE function [dbo].[fcn_ssrsrb_TankInfo]    
 (@cmp_id as varchar(100))    
     
returns varchar(max)    
    
as    
    
begin    
    
 declare @TankList as varchar(max)    
    
 set @TankList = ''    
    
 declare @Tanks as Table    
  (cmd_class varchar(100),    
   ullage int)    
    
 insert into @Tanks    
 select cmd_class, sum(Ullage) from company_tankdetail    
 where cmp_id = @cmp_id    
 group by cmd_class    
    
    
     
 select     
  @TankList = @TankList + '  ' + cmd_class + REPLICATE(' ',15 - len(cmd_class)) + LTRIM(rtrim(str(ullage))) + char(10) + char(13)    
 from @Tanks    
     
     
 return @TankList    
     
end     
GO
