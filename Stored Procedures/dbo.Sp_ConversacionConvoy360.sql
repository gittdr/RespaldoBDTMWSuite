SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para obtener las posicionescada 5 minutos antes de la fecha y hora del día de hoy.
--DROP PROCEDURE Sp_obtiene_posiciones cada 7 minutos
--GO

--exec [Sp_ConversacionConvoy360]  '90b6e547-f1ea-4ca9-89dc-eb0e32d303d2'


CREATE  PROCEDURE [dbo].[Sp_ConversacionConvoy360] @IDConver varchar(5000)
AS
SET NOCOUNT ON


DECLARE @TTConversaciones TABLE(
		 sideConver varchar(50),
		 SN varchar(5000), 
		 NLCPosition varchar(5000), 
		 IdResponseDirect varchar(5000), 
		 Contents varchar(5000),
		 DTSent datetime,
		 Asunto varchar(5000),
		 Operador varchar(500))



Insert Into @TTConversaciones
select 'A' as sideConver,msg.SN,msg.NLCPosition,msg.Position AS IdResponseDirect,msg.Contents,msg.DTSent, form.Name, mpp.mpp_id
from tblMessages msg
				inner join [dbo].[tblMsgProperties] prop on msg.SN = prop.MsgSN
				inner join [dbo].[tblForms] form on prop.[Value]  = form.SN 
				inner join manpowerprofile mpp on replace(msg.[Subject], 'Macro de ','') = mpp.mpp_firstname +' ' + mpp.mpp_lastname
				left join [dbo].[tblFormEmail] femail on form.SN =  femail.IdForm
				where NLCPosition = (@IDConver) and msg.sn = msg.BaseSN

Insert Into @TTConversaciones
select 'B',id,IdHandleResponse,IdResponse,Mensaje,DATEADD(second, DATEDIFF(second, GETUTCDATE(),GETDATE()), Fecha),'',''
from tblMessages_ResponseDirect 
where IdHandleResponse = (@IDConver)


Insert Into @TTConversaciones
select 'A' as sideConver, msg.SN,NLCPosition,Position AS IdResponseDirect,Replace(Replace(cast(Contents as varchar(5000)),' \par }',''),'{\rtf1\ansi\deff0{\fonttbl{\f0\fnil\fcharset0 Arial;}} \viewkind4\uc1\pard\lang1033\fs16 ','') ,DTSent,'' ,mpp.mpp_id
from tblMessages msg
--inner join [dbo].[tblMsgProperties] prop on msg.SN = prop.MsgSN
			
				inner join manpowerprofile mpp on replace(replace(msg.[Subject], 'Macro de ',''),'Mensaje libre de ','') = mpp.mpp_firstname +' ' + mpp.mpp_lastname
				
where 
Position in(
select Id
from tblMessages_ResponseDirect where IdHandleResponse = (@IDConver)) and 
msg.sn = BaseSN

select  * from @TTConversaciones
where IdResponseDirect not in ('invalid-value')
order by DTSent desc

GO
