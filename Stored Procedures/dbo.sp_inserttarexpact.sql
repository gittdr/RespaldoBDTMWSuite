SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec sp_inserttarexpact

CREATE proc [dbo].[sp_inserttarexpact] 


 AS

SET NOCOUNT ON

declare @tnum int
declare @descripcion varchar(200)
declare @startdate datetime
declare @enddate datetime
declare @cliente varchar(25)
declare @hoy datetime



declare @v_registros int
declare @respon varchar(20)
declare @v_i int
declare @tarexp table (tnum int, descripcion varchar(200), startdate datetime, enddate datetime, cliente varchar(25))

select @hoy = (select getdate())


select @respon = (select usr_userid from ttsusers where usr_contact_number = 'pricing')

insert  into @tarexp
SELECT distinct	tariffheader.tar_number as [Tariff Number],
       	tar_description as [Description],
       	trk_startdate as [Start Date],
		trk_enddate as [End Date],
		trk_billto as [Cliente]  --Se agrego cliente MOAM
		
FROM   	tariffkey (NOLOCK) JOIN tariffheader (NOLOCK) on tariffkey.tar_number = tariffheader.tar_number
WHERE  	DateDiff(ww,GetDate(),trk_enddate) <= 2
AND trk_enddate >= GetDate()
ORDER BY trk_enddate ASC


--Se obtiene el total de registros de la tabla temporal
select @V_registros =  (Select count(*) From  @tarexp)
--print @V_registros
--Se inicializa el contador en 1
select @V_i = 1

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @tarexp )
	BEGIN --3 Si hay movimientos de posiciones

			-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE tarexp_Cursor CURSOR FOR 
		SELECT tnum, descripcion, startdate, enddate, cliente

		FROM @tarexp

		OPEN tarexp_Cursor 
		FETCH NEXT FROM tarexp_Cursor  INTO @tnum, @descripcion, @startdate, @enddate, @cliente
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
		BEGIN -- del cursor Unidades_Cursor --3

			insert into task (TASK_TYPE,ACTIVITY_TYPE,NAME,TASK_LINK_ENTITY_VALUE,TASK_LINK_ENTITY_TABLE_ID,DESCRIPTION,
			ORIGINAL_DUE_DATE,ASSIGNED_USER,DUE_DATE,LEAD_TIME,PRIORITY,COMPLETED_DATE,ACTIVE_FLAG,STATUS,CONTACT_NAME,
			CONTACT_PHONE,CONTACT_PHONE_EXT,CONTACT_EMAIL,BRN_ID,CREATED_DATE,CREATED_USER,MODIFIED_DATE,MODIFIED_USER,USER_DEFINED_TYPE1,
			USER_DEFINED_TYPE2,USER_DEFINED_TYPE3,USER_DEFINED_TYPE4,PENDING_CHANGES_FLAG,PROMPT_ADD_FLAG,GENERATION_RULE_FLAG,
			PROMPT_EDIT_FLAG,PROMPT_DELETE_FLAG,PROMPT_HOLD_FLAG,END_DATE,ALL_DAY_EVENT,REMINDER_ENABLED,REMINDER_INTERVAL,
			REMINDER_UNITS,SNOOZED,SNOOZE_INTERVAL,SNOOZE_UNITS)


				values ('ACTVTY','TEXP','Tarifa: ' +cast(@tnum as varchar(4)) +' '+  @descripcion  + ' expira el: ' + cast(@enddate as varchar(25)), @cliente,2,'Tarifa: ' + cast(@tnum as varchar(4)) +' '+  @descripcion + ' expira el: ' + cast(@enddate as varchar(25)),
				@hoy,@respon,@hoy,0,200, dateadd(dd,-5,@enddate) ,'Y','OPEN',
				' ','','','','UNKNOWN',
				@hoy,'sa',@hoy,'sa','UNK','UNK','UNK','UNK','N','N','N','N','N','N',@hoy,0,1,45,0,0,0,0)


	   FETCH NEXT FROM tarexp_Cursor  INTO @tnum, @descripcion, @startdate, @enddate, @cliente
	
	  END 

	CLOSE tarexp_Cursor
	DEALLOCATE tarexp_Cursor

END
GO
