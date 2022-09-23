CREATE TABLE [dbo].[serviceexception]
(
[sxn_stp_number] [int] NOT NULL,
[sxn_sequence_number] [int] NOT NULL IDENTITY(1, 1),
[sxn_asgn_type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_expcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_expdate] [datetime] NOT NULL,
[sxn_mov_number] [int] NOT NULL,
[sxn_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_createddate] [datetime] NOT NULL,
[sxn_affectspay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxn_actioncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_actionuserid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_actiondate] [datetime] NULL,
[sxn_description] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_ord_hdrnumber] [int] NULL,
[sxn_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_cty_code] [int] NULL,
[sxn_action_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_delete_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_deletedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_deleteddate] [datetime] NULL,
[sxn_late] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [AddLateDflt] DEFAULT ('UNK'),
[sxn_contact_customer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [AddContCustDflt] DEFAULT ('N'),
[sxn_action_received] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [AddActRecvDflt] DEFAULT ('N'),
[sxn_action_received_desc] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_root_cause] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_car_caused] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_responsible_party] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_responsible_party_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxn_terminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Drop trigger ingresa_serviceexception

CREATE TRIGGER [dbo].[ingresa_serviceexception]
ON [dbo].[serviceexception] FOR INSERT
AS

DECLARE 
	@V_sequence_number int,
	@V_asgn_type varchar(3), 
	@V_asgn_id varchar(13),           
	@V_expcode varchar(6), 
	@V_expdate datetime,           
	@V_mov_number integer, 
	@V_createdby varchar(20),           
	@V_createddate datetime, 
	@V_description varchar(255), 
	@V_ord_hdrnumber integer,           
	@V_cmp_id varchar(8), 
	@V_action_description varchar(255), 
	@V_action_received_desc varchar(30),
	@V_Correoelectronico varchar(128),
	@lsContenido varchar(100),
	@ls_unidad   varchar(8),
	@lsDeliverTo		Varchar(10),
	@liFolder 		INT, 
	@li_tbl_SN		INT,
	@li_defaultdriver	INT,
	@li_flota		INT,
	@li_inboxflota		INT,
	@ls_documentoviaje	varchar(8),
	@V_cmp_billto 		varchar(8)

	/* Se hace el select para obtener los datos de la Excepcion que se esta aceptando o cancelando */
	SELECT 	@V_sequence_number	= b.sxn_sequence_number,
		@V_asgn_type 		= b.sxn_asgn_type,
		@V_asgn_id 		= b.sxn_asgn_id,
		@V_expcode 		= b.sxn_expcode,
		@V_expdate 		= b.sxn_expdate,
		@V_mov_number 		= b.sxn_mov_number,
		@V_createdby 		= b.sxn_createdby,
		@V_createddate 		= b.sxn_createddate,
		@V_description 		= b.sxn_description,
		@V_ord_hdrnumber 	= b.sxn_ord_hdrnumber,
		@V_cmp_id  		= b.sxn_cmp_id,
		@V_action_description 	= b.sxn_action_description,
		@V_action_received_desc = b.sxn_action_received_desc 
	FROM 	serviceexception a,
		inserted b
	WHERE 	a.sxn_sequence_number	  = b.sxn_sequence_number  

	IF @V_sequence_number > 0 

	-- Obtenemos el numero de la unidad por medio del movimiento.
		
		select @ls_unidad = ord_tractor
		from orderheader 
		where ord_hdrnumber = @V_ord_hdrnumber;


		SELECT @li_tbl_SN = Trucks.SN, @li_defaultdriver = Trucks.DefaultDriver, 
		       @liFolder = Trucks.Inbox,  @lsDeliverTo = Cab.UnitID,
		       @li_flota = Trucks.CurrentDispatcher
		FROM TMWSuite..tblTrucks Trucks, TMWSuite..tblCabUnits Cab 
		WHERE 	Trucks.Truckname = @ls_unidad  and Cab.SN = Trucks.DefaultCabUnit;

		-- Toma el nombre de la flota
				SELECT  @li_inboxflota = Inbox 
				FROM tblDispatchGroup flota 
				WHERE SN = @li_flota


		-- identifica que tipo de excepcion es?
		IF @V_asgn_type = 'USR' --Usuario
		BEGIN
			-- va a la tabla de usuarios para obtener su correo electronico.
			Select @V_Correoelectronico = usr_mail_address 
			From TMWSuite..ttsusers 
			Where usr_userid = @V_asgn_id;
	
			IF @V_Correoelectronico ='UNKNOWN'  or @V_Correoelectronico = ''
				Begin
				select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)
				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, 'Configurar el correo de '+@V_asgn_id , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
				End
			Else
				Begin
				select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)

				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , @V_Correoelectronico , @li_tbl_SN, @li_defaultdriver,0,0,2)

				End			

		END

	IF @V_asgn_type = 'CMP' --Compañia
		BEGIN
		-- Se obtiene el dato de quien documento y el billto de la orden
			Select @ls_documentoviaje = ord_bookedby, @V_cmp_billto = ord_billto 
			From orderheader 
			Where ord_hdrnumber = @V_ord_hdrnumber

			-- va a la tabla de usuarios para obtener su correo electronico de quien documento
			Select @V_Correoelectronico = usr_mail_address 
			From TMWSuite..ttsusers 
			Where usr_userid = @ls_documentoviaje;


			IF @V_Correoelectronico ='UNKNOWN' or @V_Correoelectronico = ''
				Begin
				select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)

				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, 'Configurar el correo de '+@ls_documentoviaje , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
				 -- Inserta correo a Mayra Velazquez clientes
				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'epelayo@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)

				End
			Else
				Begin
				select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)

				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , @V_Correoelectronico , @li_tbl_SN, @li_defaultdriver,0,0,2)


				 -- Inserta correo a Mayra Velazquez clientes
				 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
				  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
				  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'epelayo@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)

				End

			--analizar la posibilidad de enviarle al vendedor.

		END --cuando es compañia

		-- cuando se trata del Driver

		IF @V_asgn_type = 'DRV' --DRIVER
			BEGIN
			-- Se obtiene el dato de quien documento y el billto de la orden
				Select @ls_documentoviaje = ord_bookedby, @V_cmp_billto = ord_billto 
				From orderheader 
				Where ord_hdrnumber = @V_ord_hdrnumber
	
				-- va a la tabla de usuarios para obtener su correo electronico de quien documento
				Select @V_Correoelectronico = usr_mail_address 
				From TMWSuite..ttsusers 
				Where usr_userid = @ls_documentoviaje;
	
	
				IF @V_Correoelectronico ='UNKNOWN' or @V_Correoelectronico = ''
					Begin
					select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)
	
					 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
					  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, 'Configurar el correo de '+@ls_documentoviaje , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
					 -- Inserta correo a Mayra Velazquez clientes
					 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
					  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'epelayo@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
	
					End
				Else
					Begin
					select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)
	
					 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
					  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , @V_Correoelectronico , @li_tbl_SN, @li_defaultdriver,0,0,2)
	
	
					 -- Inserta correo a Mayra Velazquez clientes
					 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
					  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
					  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'epelayo@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
	
					End
	

		END --cuando es DRIVER

	IF @V_asgn_type = 'TRC' --Tractor
		BEGIN

		-- Se obtiene el dato de quien documento y el billto de la orden
		Select @ls_documentoviaje = ord_bookedby, @V_cmp_billto = ord_billto 
		From orderheader 
		Where ord_hdrnumber = @V_ord_hdrnumber

		-- va a la tabla de usuarios para obtener su correo electronico.
		Select @V_Correoelectronico = usr_mail_address 
		From TMWSuite..ttsusers 
		Where usr_userid = @ls_documentoviaje;

		IF @V_Correoelectronico ='UNKNOWN' or @V_Correoelectronico = ''
			Begin
			select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)

			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, 'Configurar el correo de '+@ls_documentoviaje , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)

			-- Se envia la inf a Mtto Andres Estrada
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'aestrada@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)

			End
		Else
			Begin
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , @V_Correoelectronico , @li_tbl_SN, @li_defaultdriver,0,0,2)

			-- Se envia la inf a Mtto Andres Estrada
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'aestrada@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
			End
		END


	IF @V_asgn_type = 'TRL' --Trailer
		BEGIN
		-- Se obtiene el dato de quien documento y el billto de la orden
			Select @ls_documentoviaje = ord_bookedby, @V_cmp_billto = ord_billto 
			From orderheader 
			Where ord_hdrnumber = @V_ord_hdrnumber

		-- va a la tabla de usuarios para obtener su correo electronico.
			Select @V_Correoelectronico = usr_mail_address 
			From TMWSuite..ttsusers 
			Where usr_userid = @ls_documentoviaje;



		select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)


		IF @V_Correoelectronico ='UNKNOWN' or @V_Correoelectronico = ''
			Begin
			select @lsContenido = Left('Exc.Orden No. '+ convert(varchar(10),@V_ord_hdrnumber)+ ' Motivo '+@V_description,100)

			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, 'Configurar el correo de '+@ls_documentoviaje , 'jrlopez@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)

			-- Se envia la inf a Mtto Andres Estrada
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'aestrada@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
			End
		Else
			Begin
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , @V_Correoelectronico , @li_tbl_SN, @li_defaultdriver,0,0,2)

			-- Se envia la inf a Mtto Andres Estrada
			 INSERT INTO TMWSuite..tblMessages (Type, Status, Priority, FromType, DelivertoType, DTSent, DTReceived, FOLDER,
			  Contents, FromName, Subject, DeliverTo, FromDrvSN, FromTrcSN,  OrigMsgSN, ReplyFormID, ReplyPriority )
			  Values(1, 1, 2, 1, 2, GetDate(), Null, 365, @lsContenido, @ls_unidad, @lsContenido , 'aestrada@tdr.com.mx' , @li_tbl_SN, @li_defaultdriver,0,0,2)
			End
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[ut_serviceexception] on [dbo].[serviceexception] for update as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @ls_olddata varchar(255),
		@ls_newdata varchar(255)

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

 if update(sxn_asgn_type)
 begin
	select @ls_olddata = sxn_asgn_type from deleted
	select @ls_newdata = sxn_asgn_type from inserted
	insert into serviceexceptionaudit (sxn_mov_number ,sxn_stp_number,sxn_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm)
	(select sxn_mov_number ,sxn_stp_number,sxn_sequence_number,'Type',@ls_olddata,@ls_newdata,@tmwuser,current_timestamp from inserted)	
	
 end	 
	
 if update(sxn_asgn_id)
 begin
	select @ls_olddata = sxn_asgn_id from deleted
	select @ls_newdata = sxn_asgn_id from inserted
	insert into serviceexceptionaudit (sxn_mov_number ,sxn_stp_number,sxn_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm)
	(select sxn_mov_number ,sxn_stp_number,sxn_sequence_number,'ID',@ls_olddata,@ls_newdata,@tmwuser,current_timestamp from inserted)	
	
 end	 
	
 if update(sxn_affectspay)
 begin
	select @ls_olddata = sxn_affectspay from deleted
	select @ls_newdata = sxn_affectspay from inserted
	insert into serviceexceptionaudit (sxn_mov_number ,sxn_stp_number,sxn_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm)
	(select sxn_mov_number ,sxn_stp_number,sxn_sequence_number,'Affects Pay',@ls_olddata,@ls_newdata,@tmwuser,current_timestamp from inserted)	
	
 end	 


 if update(sxn_expcode)
 begin
	select @ls_olddata = sxn_expcode from deleted
	select @ls_newdata = sxn_expcode from inserted
	insert into serviceexceptionaudit (sxn_mov_number ,sxn_stp_number,sxn_sequence_number,sxa_change_column,sxa_old_value,sxa_new_value,sxa_userid,sxa_dttm)
	(select sxn_mov_number ,sxn_stp_number,sxn_sequence_number,'Exp Code',@ls_olddata,@ls_newdata,@tmwuser,current_timestamp from inserted)	
	
 end	 




GO
ALTER TABLE [dbo].[serviceexception] ADD CONSTRAINT [pk_serviceexception] PRIMARY KEY CLUSTERED ([sxn_sequence_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sxn_mov_number] ON [dbo].[serviceexception] ([sxn_mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[serviceexception] TO [public]
GO
GRANT INSERT ON  [dbo].[serviceexception] TO [public]
GO
GRANT REFERENCES ON  [dbo].[serviceexception] TO [public]
GO
GRANT SELECT ON  [dbo].[serviceexception] TO [public]
GO
GRANT UPDATE ON  [dbo].[serviceexception] TO [public]
GO
