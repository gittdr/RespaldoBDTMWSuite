SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[vista_reportetaskcrm]


as

SELECT SUBSTRING(CONVERT(VARCHAR(11),DUE_DATE,106),3,10) as mes,
(select name from labelfile where labeldefinition = 'Task Status' and abbr = status) as estatus,
dUE_DATE,TASK_LINK_ENTITY_VALUE,CONTACT_NAME,nAME,aSSIGNED_USER,ACTIVITY_TYPE,DESCRIPTION FROM TASK
where (ACTIVITY_TYPE <> 'TEXP' )
GO
GRANT SELECT ON  [dbo].[vista_reportetaskcrm] TO [public]
GO
