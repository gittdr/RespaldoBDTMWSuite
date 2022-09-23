SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_auditanotaout]
	
AS
BEGIN

declare	
  @hdrorden int
 ,@mov  varchar(100)
 ,@statusmov char(8)
 ,@nota  varchar(255)


/*--------------------------------------------------------------*/

--seleccionamos los valores recien insertados su columna tar_number es NULL 


  SELECT  @hdrorden = ord_hdrnumber, @nota =  'Sal de ' +  replace(replace(replace(substring(update_note,1,len(update_note)-3),substring(substring(update_note,1,len(update_note)-3),charindex(':',substring(update_note,1,len(update_note)-3))+3, (len(substring(update_note,1,len(update_note)-3))+3) - charindex('>',substring(update_note,1,len(update_note)-3))),''),cast(year(getdate()) as varchar)+'-',''),'):',')')  +'->' +updated_by 
    ,@mov = key_value  FROM    tmwsuite.dbo.expedite_audit
    WHERE   (activity = 'Depart Date Changed') 
    and join_to_table_name = 'stops' and updated_By <> 'NT AUTHORITY\SYSTEM'
    and tar_number is NULL


--Sacamos el status del movimiento.
select @statusmov = stp_status  from stops where stp_number = @mov

-- revisamos  si el status del movimiento es 'DNE'-> A  para insertar la nota


if @statusmov = 'DNE' 

    BEGIN
        exec dx_add_note 'orderheader',@hdrorden, 0,0, @nota, 'N',null,''

		--insert into notes (not_number,not_text, not_urgent,not_senton,ntb_table,nre_tablekey,not_sequence,last_updatedby,last_updatedatetime)
		--VALUES (@ultnot+1,@nota,'N','12/31/49','orderheader',cast(@hdrorden as char(8)),@seq+1,'OrdMod',getdate())

   END


--ponemos todos los valores de tar_number en 0 en donde correspondan


     update expedite_audit  
     set tar_number = 0
     WHERE     (tar_number IS NULL) AND (activity = 'Depart Date Changed') 
     and join_to_table_name = 'stops' and updated_By <> 'NT AUTHORITY\SYSTEM'
	
 


END
GO
