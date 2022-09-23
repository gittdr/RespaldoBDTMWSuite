SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Original
/*se ejecuta doble el SET ANSI_NULLS ON */
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 14/03/2013
-- Description:	 Inserta expiraciones de acuerdo a las condiciones de numero de placa para inspecciones fisico mecanicas
--mod 25&11&2013 para insertar las del 2015
-- =============================================

--IMPORTANTE ESTA PARA CORRER DENTRO DEL MISMO ANIO DE LAS EXPIRACIONES A INSERTAR


--exec sp_insertaexpICFMTRL '435447'

CREATE PROCEDURE [dbo].[sp_insertaexpICFMTRL] (
@trailer varchar (8)
) AS


DECLARE  	 
	@f_fecha  datetime,
    @s_fecha  datetime,
	@placas   varchar(20),
    @tipo varchar(25)
	 

	SET ANSI_NULLS ON 
	SET ANSI_NULLS ON 
	SET ANSI_warnings ON 


	select  @placas = trl_licnum, @tipo =  trl_equipmenttype
 	from trailerprofile
	WHERE   trl_number= @trailer 

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--asignamos a la variable F_fecha la fecha para el primer semestre de acuerdo a las placas
--asignamos a la variable s_fecha la fecha para el segundo semestre de acuerdo a las placas




if  @tipo = 'DOLLY'
	begin
		 set @F_fecha = dateadd(yy,datediff(yy,'2015-03-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-03-01'))
		 set @s_fecha =  dateadd(yy,datediff(yy,'2015-09-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-09-01'))
    end


if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '1'
	begin
		 set @F_fecha = dateadd(yy,datediff(yy,'2015-04-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-04-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-10-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-10-01'))
    end

else  if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '2'
   begin
		 set @F_fecha = dateadd(yy,datediff(yy,'2015-04-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-04-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-10-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-10-01'))
    end

else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '3'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-03-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-03-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-09-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-09-01'))
    end

else if @tipo = 'TRAILER' AND  substring(@placas,3,1)  = '4'

begin
	    set @F_fecha =  dateadd(yy,datediff(yy,'2015-03-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-03-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-09-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-09-01'))
    end

else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '5'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-01-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-01-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-07-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-07-01'))
    end

else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '6'

begin
	    set @F_fecha =  dateadd(yy,datediff(yy,'2015-01-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-01-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-07-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-07-01'))
    end
else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '7'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-02-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-02-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-08-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-08-01'))
    end
else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '8'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-02-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-02-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-08-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-08-01'))
    end
else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '9'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-05-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-05-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-11-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-11-01'))
    end
else if @tipo = 'TRAILER' AND substring(@placas,3,1)  = '0'

begin
		set @F_fecha =  dateadd(yy,datediff(yy,'2015-05-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-05-01'))
		set @s_fecha =  dateadd(yy,datediff(yy,'2015-11-01',dateadd(yy,0,getdate())),dbo.ufn_GetLastDayOfMonth('2015-11-01'))
    end




-------------insertar expiración para el primer semestre------------------------------------------------------------------------------------------------------------------------

  INSERT INTO  TMWsuite.dbo.expiration
         ( exp_idtype,   
           exp_id,   
           exp_code,   
           exp_lastdate,   
           exp_expirationdate,   
           exp_routeto,   
           exp_completed,   
           exp_priority,   
           exp_compldate,   
           exp_updateby,   
           exp_creatdate,   
           exp_updateon,   
           exp_description,   
           exp_milestoexp,   
          -- exp_key,   
           exp_city,   
           mov_number,   
           exp_control_avl_date,   
           skip_trigger )  

  VALUES ( 'TRL',   
           @trailer,   
           'ICFM',   
           @f_fecha,   
           @f_fecha,  
           'TDRQUERE',   
           'N',   
           1,   
           '2049-12-31 23:59:00.000',   
           'ADMIN',   
           @f_fecha,   
           @f_fecha,   
        'Auto expiración creada ICFM 1er semestre '  + cast((year(getdate())+ 0) as varchar),   
           null,     
           15765,   
           null,   
           'N',   
           null )



-------------insertar expiración para el segundo semestre------------------------------------------------------------------------------------------------------------------------

  INSERT INTO  TMWsuite.dbo.expiration
         ( exp_idtype,   
           exp_id,   
           exp_code,   
           exp_lastdate,   
           exp_expirationdate,   
           exp_routeto,   
           exp_completed,   
           exp_priority,   
           exp_compldate,   
           exp_updateby,   
           exp_creatdate,   
           exp_updateon,   
           exp_description,   
           exp_milestoexp,   
          -- exp_key,   
           exp_city,   
           mov_number,   
           exp_control_avl_date,   
           skip_trigger )  

  VALUES ( 'TRL',   
           @trailer,   
           'ICFM',   
           @s_fecha,   
           @s_fecha,  
           'TDRQUERE',   
           'N',   
           1,   
           '2049-12-31 23:59:00.000',   
           'ADMIN',   
           @s_fecha,   
           @s_fecha,   
           'Auto expiración creada ICFM 2do semestre'  + cast((year(getdate())+ 0) as varchar),     
           null,     
           15765,   
           null,   
           'N',   
           null )


GO
