SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 27 nov 2018 4.59 pm 
-- Version: 0.1
-- Description:	

   /* Sentencia de prueba

        exec [sp_RecalculoPayWorkCycle] 'ALL', 'ALL'
	    exec [sp_RecalculoPayWorkCycle] 'HERJU06', 'OPER'
		exec [sp_RecalculoPayWorkCycle] 'CEMEX', 'PROY'
		exec [sp_RecalculoPayWorkCycle] 'ALL','QUEU'
	*/


-- =============================================
CREATE PROCEDURE [dbo].[sp_RecalculoPayWorkCycle] (@proy varchar(20), @modo varchar(20))
	

AS
BEGIN


declare @legs table (leg varchar(20))

DECLARE @leg VARCHAR(100) 
DECLARE @status varchar(5)
DECLARE @value varchar(10)
DECLARE @conta int

select @conta = 0

/**********************************************
Caso recalcular todo
**********************************************/


if (@proy = 'ALL' and @modo = 'ALL')

 begin


       insert into @legs

		select distinct lgh_number from paydetail where pyd_status = 'PND'
		and lgh_number not in ( select lgh_number from assetassignment where asgn_type  ='DRV' and pyd_status = 'PPD')
		and (lgh_number <> 0)
		order by lgh_number desc

		delete @legs where leg in (select distinct(lgh_number) from paydetail where pyd_status = 'REL')

   
		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas los legs que no tienen aun algun paydetail en RELEASE de ordenes completadas
		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


         select leg from @legs
		 order by leg desc

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @leg

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'ComputePay', @leg --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @leg) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @leg
				select @conta = @conta +1
				print 'sali del while' + cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

END


/**********************************************
Caso recalcular un solo operador en especifico
**********************************************/

if ( @modo = 'OPER' and @proy <> 'ALL')

 begin


       insert into @legs

		select distinct lgh_number from paydetail where pyd_status = 'PND'
		and lgh_number not in ( select lgh_number from assetassignment where asgn_type  ='DRV' and pyd_status = 'PPD')
		and (lgh_number <> 0)
		and asgn_id = @proy
		order by lgh_number desc

		delete @legs where leg in (select distinct(lgh_number) from paydetail where pyd_status = 'REL')

   
		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas los legs que no tienen aun algun paydetail en RELEASE de ordenes completadas
		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


         select leg from @legs
		 order by leg desc

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @leg

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'ComputePay', @leg --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @leg) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @leg
				select @conta = @conta +1
				print 'sali del while' + cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

END

/**********************************************
Caso recalcular un proyecto de operador en especifico
**********************************************/

if ( @modo = 'PROY' and @proy <> 'ALL')

 begin


       insert into @legs

		select distinct lgh_number from paydetail where pyd_status = 'PND'
		and lgh_number not in ( select lgh_number from assetassignment where asgn_type  ='DRV' and pyd_status = 'PPD')
		and (lgh_number <> 0)
		and asgn_id in (select mpp_id from manpowerprofile where (select name from labelfile where labeldefinition = 'drvtype3' and abbr = mpp_type3)  = @proy)
		order by lgh_number desc

		delete @legs where leg in (select distinct(lgh_number) from paydetail where pyd_status = 'REL')

   
		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas los legs que no tienen aun algun paydetail en RELEASE de ordenes completadas
		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/


         select leg from @legs
		 order by leg desc

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @leg

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'ComputePay', @leg --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @leg) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @leg
				select @conta = @conta +1
				print 'sali del while' + cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

END

END
/**********************************************
Caso desplegar informacion de lo que hay en cola
**********************************************/

if ( @modo = 'QUEU' and @proy <> 'ALL')

print 'QUEUE'
 begin


       insert into @legs

		select distinct lgh_number from paydetail where pyd_status = 'PND'
		and lgh_number not in ( select lgh_number from assetassignment where asgn_type  ='DRV' and pyd_status = 'PPD')
		and (lgh_number <> 0)
		order by lgh_number desc

		delete @legs where leg in (select distinct(lgh_number) from paydetail where pyd_status = 'REL')

   
         select leg,
		 (select ord_hdrnumber from legheader where leg = lgh_number) as Orden,
		 (select lgh_Driver1 from legheader where leg = lgh_number) as Operador
		 from @legs
		 
		


END




GO
