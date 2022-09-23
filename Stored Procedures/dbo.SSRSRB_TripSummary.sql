SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SSRSRB_TripSummary]      
 (@Date as date,      
  @Terminal as varchar(max),      
  @Shift as varchar(max))      
        
        
as      
      
set transaction isolation level read uncommitted      
      
-- SSRSRB_TripSummary '2014-03-07', 'SD,X', 'AM'      
      
DECLARE @TerminalList table (Terminal varchar(100))

INSERT INTO @TerminalList
SELECT value FROM dbo.CSVStringsToTable_fn (@Terminal)

--select * from @TerminalList
    
      
select       
      
 -- Order Header      
 ord.ord_hdrnumber,       
 ord.ord_number,       
 lgh.mfh_number,      
 DATEDIFF(mi,lgh.lgh_startdate, lgh.lgh_enddate)/60.0 'Trip Time',      
       
 -- Driver/Truck/Shift      
 Term.name 'Terminal',      
 ss.ss_date 'Shift Date',      
 ss.ss_shift 'Shift',      
 case when lgh.lgh_carrier = 'UNKNOWN' then       
  lgh.lgh_tractor       
 else       
  lgh.lgh_carrier       
 end 'TruckCarrier',      
 mpp.mpp_id,      
 mpp.mpp_lastfirst,      
       
 'Customer: ' + isnull(stpCmp.cmp_id,'') + char(13) + char(10) + 'Alt: ' + isnull(stpCmp.cmp_altid,'') + char(13) + char(10) +     
 'Petroex: ' + isnull(stpCmp.cmp_misc3,'') 'CompanyFACPetrex',    
      
 -- Stop      
 DENSE_RANK() over (Partition by mpp.mpp_id,lgh.mfh_number order by stp.stp_mfh_sequence) DropSeq,      
 stp.stp_mfh_sequence,      
 stpCmp.cmp_id 'Stop Company',      
 stpCmp.cmp_name 'Stop Company Name',      
 stpCmp.cmp_address1 'Stop Address1',      
 isnull(stpCmp.cmp_address2,'') 'Stop Address2',      
 stpCty.cty_name + ', ' + stpCty.cty_state 'Stop City',      
 SUBSTRING(stpCmp.cmp_primaryphone,1,3) + '-' + SUBSTRING(stpCmp.cmp_primaryphone,4,3) + '-' + SUBSTRING(stpCmp.cmp_primaryphone,7,4) 'Stop Phone',      
 dbo.fcn_ssrsrb_tankinfo(stpCmp.cmp_id) 'TankList',      
 dbo.TMWSSRS_fcn_ssrsrb_FreightLines(stp.stp_number) 'Freight Qtys',  
   
   
   
 stp.stp_schdtearliest,     
 stp.stp_schdtlatest,    
     
 stpCmp.cmp_altid 'Stop Alt ID',      
 stpCmp.cmp_misc1 'Stop Misc1',      
 stpCmp.cmp_misc2 'Stop Misc2',      
 stpCmp.cmp_misc3 'Stop Misc3',      
       
       
       
       
 -- freight      
       
 fgt.cmd_code,      
 fgt.fgt_description,    
 fgt.fgt_volume,      
 substring(shpCmp.cmp_name,1,10) 'Shipper',      
 (select top 1 substring(cmp_name,1,10) from stops s   
  where stp_event = 'EMT' and s.lgh_number = lgh.lgh_number) 'TripEnd',  
       
 ord.ord_remark      
       
        
        
       
      
from shiftschedules ss      
 inner join legheader lgh on lgh.shift_ss_id = ss.ss_id      
 inner join stops stp on stp.lgh_number = lgh.lgh_number and stp.stp_type = 'DRP'      
 inner join orderheader ord on ord.ord_hdrnumber = stp.ord_hdrnumber       
 inner join company BillTo on BillTo.cmp_id = ord.ord_billto      
 inner join company stpCmp on stpCmp.cmp_id = stp.cmp_id      
 inner join city stpCty on stpCty.cty_code = stpCmp.cmp_city      
 inner join labelfile Term on Term.labeldefinition = 'Terminal' and Term.abbr = ss.ss_terminal       
 inner join freightdetail fgt on fgt.stp_number = stp.stp_number      
 inner join manpowerprofile mpp on mpp.mpp_id = lgh.lgh_driver1      
 inner join company shpCmp on shpCmp.cmp_id = fgt.fgt_shipper       
 inner join @TerminalList TL on TL.Terminal = ss.ss_terminal
where ss.ss_date = @Date      
   and ss.ss_shift = @Shift
GO
