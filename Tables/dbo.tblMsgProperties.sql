CREATE TABLE [dbo].[tblMsgProperties]
(
[MsgSN] [int] NOT NULL,
[PropSN] [int] NOT NULL,
[Value] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Emilio Olvera
-- Create date: 18 Julio 2017
-- Description:	inserta mensaje de error totalmail para operador
-- =============================================
CREATE TRIGGER [dbo].[trg_it_inserterrormsgtmail]
   ON  [dbo].[tblMsgProperties]
   AFTER  INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

 if ( (select PropSN from inserted) = 6)

  BEGIN 

	DECLARE
	@errlistid int,
	@mensaje varchar(max),
	@destino varchar(20),
	@msgns int,
	@subject varchar(255),
	@msgfinal varchar(max)


	  select @errlistid = value, @msgns = MsgSN from inserted
	   
	  if ( select OrigMsgSN  from tblMessages nolock  where sn = @msgns) =  @msgns

	   begin 

	  

		  select 

	
		 @mensaje =  
		case when b.description like  '%remolque%' then 'Error en remolque' 
		  when b.description like  '%Trailer not on file or assigned to that move%' then 'Error en remolque'
		  when b.description like  '%Change of trailer not permitted or missing Primary Trailer%' then 'Error en remolque'
		  when b.description like '%uses a value of the wrong type%'  then 'ConversionSPTMW'
		  when b.description like '%El recurso ingresado esta en uso en otra orden%' then 'El recurso esta en uso en otra orden'
		   when b.description like '%The equipment is already in use%' then 'El recurso esta en uso en otra orden'
		  when b.description like '%The equipment is in use on another trip%' then 'El recurso esta en uso en otra orden'
		  when b.description like '%Earlier activity for the move has not yet been completed%'  then 'Actividad previa para el movimiento no completada'
		  when b.description like '%Later stop is already completed%' then 'Stop posterior ya completado'
		  when b.description like '%That Trip Segment is already started%' then 'Viaje ya iniciado'
		  when b.description like '%Applicable order number not found%' then 'Numero de orden invalido'
		  when b.description like '%Specified date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
		  when b.description like '%Specified date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
		  when b.description like '%Departure date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
		  when b.description like '%Arrival or Departure date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
		  when b.description like  '%Tractor not found or not assigned/dispatched to that move%' then 'Tractor no encontrado o asignado a la orden'
		  when b.description like  '%Operador no existente o no asignado a la orden%' then 'Operador no encontradoo o no asignado a la orden'
		  when b.description like  '%or that tractor not assigned to it%' then 'Tractor no asignado a la orden, cambio de tractor de operador'
		  when b.description like  '%Driver not found or not assigned to that move%' then 'Operador no asignado a la orden, cambio de tractor de operador'
		  when b.description like '%SQL Server%' then 'Error SQL'
		  when b.description like '%Parse%' then 'Error Parseo SQL'
		  when b.description like '%Unrecognized unit of measure%' then 'Unidad de medida no reconocida'
		  when b.description like '%There is other incomplete activity in progress on that move%' then 'Actividad previa para el movimiento no completada'
		  else 'No clasificado'
		  end + ' | ' +isnull(substring(description,CHARINDEX('°',description), 1000),'')
	 
         from  tblErrorData b where b.ErrListID =  @errlistid
		 and b.description not like '%Later stop is already completed%' 

		 
		  set @destino = (select FromName from tblmessages where SN = @msgns)
		  set @subject = (select Subject from tblmessages where SN = @msgns)




		   set @msgfinal = (  ' Favor de contactar a tu Lider de Proyecto para que corrija tu orden: '+isnull(@subject,'') + '**, ERROR : "  '+ @mensaje )

	

		 if ((@destino <> 'null' ) and (@msgfinal <> 'null'))
		   begin
		  
          
		    exec tm_insertamensaje @msgfinal , @destino
		      


		   end

	

	  END


	END
  END
END


GO
ALTER TABLE [dbo].[tblMsgProperties] ADD CONSTRAINT [PK_tblMsgProperties_MsgSN] PRIMARY KEY CLUSTERED ([MsgSN], [PropSN]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMsgProperties] ADD CONSTRAINT [FK__Temporary__MsgSN__23143DEA] FOREIGN KEY ([MsgSN]) REFERENCES [dbo].[tblMessages] ([SN]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblMsgProperties] ADD CONSTRAINT [FK__Temporary__PropS__24086223] FOREIGN KEY ([PropSN]) REFERENCES [dbo].[tblPropertyTypes] ([SN])
GO
