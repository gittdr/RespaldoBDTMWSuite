SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create view [dbo].[OrdenesSAE] as  
Select * from orderheader
where ord_bookdate>='2019-01-01'
and ord_billto='SAE'
GO
