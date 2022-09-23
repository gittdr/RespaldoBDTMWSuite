SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE PROCEDURE [dbo].[sp_datosRecalculoWorkCycle]
	
AS
BEGIN

select 
			 ord_number
			 , case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end as Error

			from orderheader 
			where  ord_totalcharge <=	1500 and ord_completiondate >= '2020-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'
			and ord_hdrnumber not in 
				(select ord_hdrnumber from invoiceheader where ivh_invoicestatus = 'XFR' and ord_hdrnumber in(select ord_hdrnumber from orderheader 
				where ord_totalcharge = 1500 and ord_completiondate >= '2020-01-01' and ord_status = 'CMP' and ord_invoicestatus = 'AVL' and ord_completiondate < CONVERT(varchar, getdate(), 101)))
			order by cast (ord_hdrnumber as int)desc



END


















GO
