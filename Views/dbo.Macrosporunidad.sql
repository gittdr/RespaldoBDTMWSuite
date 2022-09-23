SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create View [dbo].[Macrosporunidad]
as
select SN, subject, day(DTSent) dia ,month(DTSent) Mes , year(DTSent) año ,FromName , DeliverTo from tblMessages where SN in (
select MsgSN from tblMsgProperties where DTSent >'12-01-2011' ) and deliverTotype = 3 and status = 4
and subject <> '       *** MENSAJE DE TEXTO ***'  and FromName <> '501'  and Folder = '373'


GO
