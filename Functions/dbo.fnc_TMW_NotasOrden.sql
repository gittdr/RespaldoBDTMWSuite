SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Autor: Emilio Olvera
Ver: 1.0
Fecha: 16 de Abril 2015

sentencia de prueba select * from fnc_TMW_NotasOrden('323940')
*/



CREATE FUNCTION [dbo].[fnc_TMW_NotasOrden]  (@orden varchar(20))

Returns  @notasorden table
 ( not_number  varchar (20),            
   NotaAlerta  varchar (8),
   Nivel varchar(30),
   Tipo varchar(60),
   Texto text,
   Usuario varchar(200),
   Fecha datetime,
   not_sequence int,
   nre_tablekey char(18),
   ntn_table varchar(30)


 )

as

--Declaracion y asignación de variables para los querys internos.
begin

declare @tablatemp table
 ( valor  varchar (20),            
   tipo  varchar (40)                  
 )



   insert into @tablatemp

   select ord_fromorder,'orderheader' from orderheader  nolock where ord_hdrnumber = @orden and ord_fromorder is not null
   union
   select cast(mov_number as varchar(20)),'movement'  from orderheader nolock where ord_hdrnumber =  @orden
   union
   select cast(lgh_number as varchar(20)) ,'legheader' from legheader nolock where ord_hdrnumber = @orden
   union
   select cast(lgh_driver1 as varchar(20)),'manpowerprofile' from legheader nolock where ord_hdrnumber =  @orden
   union
   select lgh_driver2,'manpowerprofile' from legheader nolock where ord_hdrnumber = @orden
   union
   select lgh_tractor,'tractorprofile' from legheader nolock where ord_hdrnumber = @orden
   union
   select lgh_primary_trailer,'trailerprofile' from legheader nolock where ord_hdrnumber = @orden
   union
   select lgh_primary_pup,'trailerprofile' from legheader nolock where ord_hdrnumber = @orden
   union
   select lgh_carrier,'carrier' from legheader nolock where ord_hdrnumber = @orden
   union
   select ord_billto,'company' from orderheader nolock where ord_hdrnumber = @orden
   union 
   select @orden,'orderheader'


 
   insert into  @notasorden

   select  not_number, 
   case when not_urgent = 'N' then 'Nota' else 'Alerta' end as NotaAlerta, 
   replace(isnull((select name from labelfile where abbr = not_viewlevel and labeldefinition = 'NotesLevel'),''),'UNKNOWN','UNK') as 'Nivel',
   isnull((select name from labelfile where labeldefinition = 'NoteRe' and abbr =  not_type),'') as Tipo,
   not_text as 'Texto',
   isnull((select  last_updatedby+' | '+ usr_fname + ' ' + usr_lname from ttsusers where usr_userid = last_updatedby)
    + '   |   '
	+(select  (select min(grp_name) from ttsgroups where  ttsgroups.grp_id =  max(ttsgroupasgn.grp_id) )  from ttsgroupasgn where usr_userid = last_updatedby)
   ,last_updatedby) as 'Usuario',
   last_updatedatetime as 'Fecha',
    not_sequence, 
	nre_tablekey,
	ntb_table
	 from notes  
   where nre_tablekey in (select valor from @tablatemp)
   

  
   RETURN

   END

	





GO
GRANT SELECT ON  [dbo].[fnc_TMW_NotasOrden] TO [public]
GO
