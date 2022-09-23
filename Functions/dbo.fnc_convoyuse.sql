SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE function [dbo].[fnc_convoyuse] (@Driver varchar(20))
returns float
begin



 declare @tempo table  (ord_hdrnumber varchar(10),ord_completiondate datetime,updatedby varchar(20))

	insert into @tempo

	



	  select ord_hdrnumber, ord_completiondate,

	  isnull((select top 1 'TMAIL' from expedite_audit_tbl e where activity  = 'OrderHeader update'

      and updated_by = 'totalmail' and update_note  = 'Status STD -> CMP' and e.ord_hdrnumber = orderheader.ord_hdrnumber),'TMW') as updatedby

	  from orderheader where ord_status = 'CMP' and ord_driver1 =  @Driver

	  and datediff(dd,ord_startdate,getdate()) <= 30

	   and ord_hdrnumber <> 0



	return (select  round( cast(( select count(*) from @tempo where updatedby = 'TMAIL') as float)  /  (.0001 + cast((select count(*) from @tempo ) as float)),2))

	 
end


GO
