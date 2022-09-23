SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LTSLExport204PreProcess] (@ID int) 
   
AS    
BEGIN
declare @stp_number int, @stp_number_last int, @stp_number_refsource int
declare @stp_mfh_sequence int, @ord_hdrnumber int, @max_ref_seq int
declare @mov_number int, @stp_number_refsource_last int
set @stp_number =  0
set @stp_number_last =  0
set @stp_number_refsource_last = 0
select top 1 @stp_number = e.stp_number, 
 @mov_number = mov_number,
 @ord_hdrnumber = e.ord_hdrnumber 
 from edi_outbound204_stops e join stops s on e.stp_number = s.stp_number where ob_204id  = @ID and e.stp_event in ('DLT','HLT')
 order by e.stp_number

while @stp_number <> @stp_number_last 
begin
 set @stp_number_last = @stp_number

 select top 1 @stp_number_refsource = stp_number 
  from stops 
  where mov_number = @mov_number 
  and stp_event not in ('DLT','HLT')
  order by stp_number 

 while @stp_number_refsource <> @stp_number_refsource_last 
 begin
  set @stp_number_refsource_last = @stp_number_refsource  

 set @max_ref_seq = 0
 select @max_ref_seq = IsNull(max(ref_sequence),0) from edi_outbound204_refs where edi_outbound204_refs.ob_204id = @ID and edi_outbound204_refs.ref_tablekey = @stp_number

 if IsNull(@stp_number_refsource,0) > 0
  INSERT INTO [dbo].[edi_outbound204_refs]
      ([ob_204id]
      ,[ord_hdrnumber]
      ,[ref_tablekey]
      ,[ref_table]
      ,[ref_sequence]
      ,[ref_type]
      ,[ref_number])
    select
      @ID
      ,ord_hdrnumber
      ,@stp_number
      ,'stops'
      ,@max_ref_seq + ref_sequence
      ,ref_type
      ,ref_number
      from [referencenumber]
      where ref_table = 'stops'
      and ref_tablekey = @stp_number_refsource
      and not exists (select 1 from [edi_outbound204_refs] where [edi_outbound204_refs].ref_tablekey = @stp_number
                   and [edi_outbound204_refs].ref_table = [referencenumber].ref_table
                   and [edi_outbound204_refs].ref_type = [referencenumber].ref_type
                   and [edi_outbound204_refs].ref_number = [referencenumber].ref_number)

  select top 1 @stp_number_refsource = stp_number 
  from stops where mov_number = @mov_number 
  and stp_event not in ('DLT','HLT')
  and stp_number > @stp_number_refsource_last 
  order by stp_number 
 end
 set @stp_number_refsource_last = 0
 select top 1 @stp_number = e.stp_number, 
  @mov_number = mov_number,
  @ord_hdrnumber = e.ord_hdrnumber 
  from edi_outbound204_stops e join stops s on e.stp_number = s.stp_number where ob_204id  = @ID and e.stp_event in ('DLT','HLT')
  and e.stp_number > @stp_number_last
  order by e.stp_number

end
END
GO
GRANT EXECUTE ON  [dbo].[LTSLExport204PreProcess] TO [public]
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'LTSLExport204PreProcess', NULL, NULL
GO
