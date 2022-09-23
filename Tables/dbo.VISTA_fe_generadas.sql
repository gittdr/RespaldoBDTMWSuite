CREATE TABLE [dbo].[VISTA_fe_generadas]
(
[nmaster] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[serie] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[idreceptor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fhemision] [datetime] NULL,
[total] [money] NULL,
[moneda] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rutapdf] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rutaxml] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[imaging] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bandera] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provfact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ultinvoice] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hechapor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orden] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rfc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referencia] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoicerel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UIDrel] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER  [dbo].[insertaref]
   ON  [dbo].[VISTA_fe_generadas]
   AFTER INSERT 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here

update dbo.VISTA_fe_generadas     set referencia = (select ord_refnum from orderheader where orden = ord_number)
where referencia = '' or referencia is null


END
GO
