SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Emilio Olvera
-- Create date: 17 nov 2018 7.17 pm 
-- Version: 1.0
-- Description:	

   /* Sentencia de prueba

        exec [sp_RecalculoOrdenesWorkCycle_Billto] 'LIVERDED'

	    exec [sp_RecalculoOrdenesWorkCycle_Billto] 'WORKC'

		  exec [sp_RecalculoOrdenesWorkCycle_Billto] 'SAYER'
	   

	   exec [sp_RecalculoOrdenesWorkCycle_Billto] 'ALL'
	*/


	---4/22/2019 se cambio el limite a 1000 pesos para recalcular. en 1500 habia muchos casos 


-- =============================================
CREATE PROCEDURE [dbo].[sp_RecalculoOrdenesWorkCycle_Billto] (@billto varchar(20))
	
AS
BEGIN


DECLARE @order VARCHAR(1000) 
DECLARE @status varchar(5)
DECLARE @value varchar(10)
DECLARE @conta int

select @conta = 0

If (@billto <>  'ALL')
 begin 


		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas las ordenes sin tarifas ordenandolas por las que ya se procesaron previamente y tuvieron errores

		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



			select 
			 ord_number

			 , case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end as Error

			from orderheader 
			
			 where   ord_totalcharge <=	5000  and --isnull(tar_number,0)  = 0
             ord_completiondate >= '2016-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'
	      and ord_billto = @billto
			order by ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) 



		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @order, @status

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'RateOrder', @order --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @order) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @order, @status
				select @conta = @conta +1
					print 'sali del while orden: ' + @order +' - ' +cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 


		END

end

/******************************************************************************** 
CASO PROCESA TODOS LOS CLIENTES TODAS LAS QUE ESTAN PENDIENTES DE PROCESAR EN WKC
*********************************************************************************/

if (@billto = 'WORKC')

 begin

   
		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas las ordenes sin tarifa pendientes de pasar a Work Cycle

		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



			select 
			 ord_number

			 , case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end as Error

			from orderheader 
			where  ord_totalcharge <=	1000 
			and ord_completiondate >= '2016-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'

			and
			case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end = 'N'



		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @order, @status

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'RateOrder', @order --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @order) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @order, @status
				select @conta = @conta +1
				print 'sali del while orden: ' + @order +' - ' +cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

END




/******************************************************************************** 
CASO PROCESA TODOS LOS CLIENTES TODAS LAS CMP PENDIENTES DE TARIFA
*********************************************************************************/

if (@billto = 'ALL')

 begin

   
		DECLARE db_cursor CURSOR FOR 

		/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		Query para recorrer todas las ordenes sin tarifas ordenandolas por las que ya se procesaron previamente y tuvieron errores

		Autor: Emolvera
		Fecha: 16 Nov 2018
		Version: 2.0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



			select 
			 ord_number

			 , case when  ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			 from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) >0 then 'Y' else 'N' end as Error

			from orderheader 
			where  ord_totalcharge <=	1000 
			and ord_completiondate >= '2020-01-01' and ord_status = 'CMP' and ord_completiondate < CONVERT(varchar, getdate(), 101)   and ord_invoicestatus = 'AVL'

			--order by ((select count(*) from workflow_Data where  Workflow_Field_Name = 'Result' and Workflow_Field_Data like 'ERROR' and workflow_id = (select max(workflow_id)
			-- from workflow where workflow_startvalue = ord_number) and workflow_field_name = 'Result')) 



		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/



		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @order, @status

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
      

	
	 
			   exec start_workflow 'RateOrder', @order --'602711'
	  

		/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Sentencia While que no deja pasar a la siguiente orden en el cursor hasta que tengamos respuesta de si el recalculo fue exitoso o fallido
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

			  WHILE ((select count(*) from workflow_Data where workflow_id = (select max(workflow_id) from workflow where workflow_startvalue = @order) and workflow_field_name = 'Result') = 0)
			   begin
				set @value=@value
			  end
	
				FETCH NEXT FROM db_cursor INTO @order, @status
				select @conta = @conta +1
				print 'sali del while orden: ' + @order +' - ' +cast(@conta as varchar(10)) 


		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

END
GO
