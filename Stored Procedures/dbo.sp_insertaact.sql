SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec sp_insertaact 'BARDAHL', '762'

CREATE proc [dbo].[sp_insertaact] 
(@cliente varchar(20),
 @listaids varchar(100)
 )

 AS

SET NOCOUNT ON

declare @taskid  int
declare @conceptos varchar(300)

Set @listaids= ',' + ISNULL(cast(@listaids as varchar(100)),'') + ','

declare @hoy datetime
declare @respons varchar(20)

select @hoy = (select getdate())

select @conceptos = 
(STUFF((select '; ' +
(select cht_description from chargetype nolock where cht_itemcode = th.cht_itemcode)
+

cast(th.tar_rate as varchar(50)) + ' ' + th.cht_currunit


FROM tariffkey (nolock) tk 
join tariffheader th on tk.tar_number =  th.tar_number
WHERE 
 (@listaids =',,' or CHARINDEX(',' + cast(th.tar_number as varchar(20))  + ',', @listaids) > 0)
and
trk_billto = @cliente
 FOR XML PATH('')) , 1, 1, ''))


select @respons =  
(select top 1 th.tar_updateby
FROM tariffkey (nolock) tk 
join tariffheader th on tk.tar_number =  th.tar_number
WHERE 
 (@listaids =',,' or CHARINDEX(',' + cast(th.tar_number as varchar(20))  + ',', @listaids) > 0)
and
trk_billto = @cliente)



select @taskid = (select task_id from task where ACTIVITY_TYPE = 'QUOTE' and
TASK_LINK_ENTITY_VALUE = @cliente  and created_date = (select max(CREATED_DATE) from task where   ACTIVITY_TYPE = 'QUOTE' and 
TASK_LINK_ENTITY_VALUE = @cliente))


select

tk.tar_number AS [ID],
(select cht_description from chargetype nolock where cht_itemcode = th.cht_itemcode) as Concepto,
th.tar_description as Descripcion,
replace((select cty_nmstct from city where cty_code = trk_origincity),'UNKNOWN','') AS [Origen],
replace((select cty_nmstct from city where cty_code = trk_destcity),'UNKNOWN','')  AS [Destino],
cast(th.tar_rate as varchar(20)) + ' ' + th.cht_currunit  as Precio,

trk_startdate AS [EffectiveFrom],
trk_enddate AS [EffectiveTo],

last_updatedate AS [ModifiedOn],
trk_billto as cliente

FROM tariffkey (nolock) tk 
join tariffheader th on tk.tar_number =  th.tar_number
WHERE 
datediff(d, getdate(),trk_enddate) >= 0
AND trk_billto = @cliente
and (@listaids =',,' or CHARINDEX(',' + cast(th.tar_number as varchar(20))  + ',', @listaids) > 0)
--regre


 If  @taskid  is not null
 
  begin

  /*
  print @taskid 
  print 'se ha generado cotización por:'  + @conceptos

  */

	insert into task_note (TASK_ID,
	NOTE_TEXT,
	CREATED_USER,
	MODIFIED_USER,CREATED_DATE,MODIFIED_DATE) values (@taskid,
	'se ha generado formato de cotización por:' + isnull(@conceptos, '')  ,
	'sa',
	'sa',GETDATE(),GETDATE());


  end

  else

   begin


insert into task (TASK_TYPE,
ACTIVITY_TYPE,
NAME,
TASK_LINK_ENTITY_VALUE,
TASK_LINK_ENTITY_TABLE_ID,
DESCRIPTION,
ORIGINAL_DUE_DATE,
ASSIGNED_USER,
DUE_DATE,
LEAD_TIME,
PRIORITY,
COMPLETED_DATE,
ACTIVE_FLAG,
STATUS,
CONTACT_NAME,
CONTACT_PHONE,
CONTACT_PHONE_EXT,
CONTACT_EMAIL,
BRN_ID,
CREATED_DATE,
CREATED_USER,
MODIFIED_DATE,
MODIFIED_USER,
USER_DEFINED_TYPE1,
USER_DEFINED_TYPE2,
USER_DEFINED_TYPE3,
USER_DEFINED_TYPE4,
PENDING_CHANGES_FLAG,
PROMPT_ADD_FLAG,
GENERATION_RULE_FLAG,
PROMPT_EDIT_FLAG,
PROMPT_DELETE_FLAG,
PROMPT_HOLD_FLAG,
END_DATE,
ALL_DAY_EVENT,
REMINDER_ENABLED,
REMINDER_INTERVAL,
REMINDER_UNITS,
SNOOZED,
SNOOZE_INTERVAL,
SNOOZE_UNITS)


values ('ACTVTY','QUOTE','Envio de cotizacion',@Cliente,2,'actividad envio cotizacion autogenerada ',
@hoy,@respons,@hoy,0,200,'2049-12-31 23:59:59','Y','OPEN',
' ','','','','UNKNOWN',
@hoy,'sa',@hoy,'sa','UNK','UNK','UNK','UNK','N','N','N','N','N','N',@hoy,0,1,45,0,0,0,0)



select @taskid = (select task_id from task where ACTIVITY_TYPE = 'QUOTE' and
TASK_LINK_ENTITY_VALUE = @cliente  and created_date = (select max(CREATED_DATE) from task where   ACTIVITY_TYPE = 'QUOTE' and 
TASK_LINK_ENTITY_VALUE = @cliente))

	insert into task_note (TASK_ID,
	NOTE_TEXT,
	CREATED_USER,
	MODIFIED_USER,CREATED_DATE,MODIFIED_DATE) values (@taskid,
	'se ha generado formato de cotización por:' + @conceptos  ,
	'sa',
	'sa',GETDATE(),GETDATE());



end



GO
