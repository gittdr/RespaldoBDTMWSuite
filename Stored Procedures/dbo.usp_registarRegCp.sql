SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_registarRegCp] (@NameFile varchar(100),@col1 varchar(200),@folio varchar(100),@serie varchar(100),@Rorder varchar(100),@ivh_invoicenumber varchar(100),@ivh_billto varchar(100),@ivh_totalcharge varchar(100),@Total varchar(100),@estatus varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    insert into InsertRegCp (folio,uuid,segmento,serie,rorder,aplica,billto,totalinvoice,totalvcartaporte,estatus) 
	values(@NameFile,@col1,@folio,@serie,@Rorder,@ivh_invoicenumber,@ivh_billto,@ivh_totalcharge,@Total,@estatus)
END
GO
