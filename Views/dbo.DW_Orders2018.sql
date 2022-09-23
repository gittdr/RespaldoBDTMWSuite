SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[DW_Orders2018] AS 

select * from orderheader
where ord_completiondate > '2021-01-01' and ord_completiondate < GETDATE() and ord_status = 'CMP'
and ord_billto <> 'SAE'
GO
