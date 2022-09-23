SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[sp_expiraaltaoperadores]

as

declare	@oper   varchar(10)
declare @hire datetime


DECLARE opcontratacion_Cursor 
          CURSOR FOR 
		SELECT mpp_id,mpp_hiredate from manpowerprofile where mpp_hireDate is not null and mpp_id <> 'JOSBA'
	
		OPEN opcontratacion_Cursor
		FETCH NEXT FROM opcontratacion_Cursor INTO @oper,@hire
		WHILE @@FETCH_STATUS = 0 
		BEGIN --2 del cursor operadores_Cursor --2

			
        if @oper not in (select exp_id from expiration where exp_code = 'INS' and exp_description = 'Fecha de contratacion' )
         begin

          -- print @oper
          -- print @hire



				INSERT INTO  TMWsuite.dbo.expiration
				( exp_idtype,   exp_id,   exp_code,   exp_lastdate,   exp_expirationdate,   
				  exp_routeto,  exp_completed,  exp_priority,   exp_compldate,   exp_updateby,   
				exp_creatdate,   exp_updateon,   exp_description, exp_milestoexp,    
				exp_city,   mov_number,   exp_control_avl_date,   skip_trigger)  

				  VALUES ( 'DRV',  @oper,   'INS',   @hire,  @hire,  
					   'TDRQUERE', 'Y',   1, @hire, 'AUTO',   
						   @hire, @hire, 'Fecha de contratacion',  Null,
						   15765,    null,   'N',  null );

          end        

			FETCH NEXT FROM opcontratacion_Cursor  INTO @oper,@hire
		
		END --2

	CLOSE  opcontratacion_Cursor
	DEALLOCATE  opcontratacion_Cursor
GO
