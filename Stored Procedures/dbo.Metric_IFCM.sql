SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_IFCM] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
    @Modo varchar (20),                         --REVISADAS, REVISADAS ACUM, POR REVISAR, PORCENTAJE, TOTAL
	@ShowDetail int


     


)
AS
	SET NOCOUNT ON  



-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Tractos,2:Remolques,3:Proyecto



	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Inspec(
	        Unidad varchar(10),FechaProgramada datetime,Descripcion varchar(500), Completada varchar(2), FechaCompletada datetime, tipounidad varchar (4), Proyecto varchar(6))
	
	CREATE TABLE #PInspec(
	        PUnidad varchar(10),PFechaProgramada datetime,PDescripcion varchar(500), PCompletada varchar(2), PFechaCompletada datetime, Ptipounidad varchar (4), PProyecto varchar(6))
	

--Cargamos la tabla temporal con los datos de la consulta de la tabla de expiraciones

IF @modo in('POR REVISAR','PORCENTAJE','TOTAL')
BEGIN

  INSERT INTO #Inspec

   Select 
            Unidad = exp_id,
            FechaProgramadas = exp_expirationdate ,
            Descripcion = exp_description,
            Completada = exp_completed,
            FechaCompletada = exp_compldate,
            TipoUnidad = exp_idtype,
            Proyecto = (case when exp_idtype = 'TRL' then (Select trl_type3 from trailerprofile where trl_number = exp_id) 
                             when exp_idtype = 'TRC' then (Select trc_type3 from tractorprofile where trc_number = exp_id)  END)
    
		         FROM expiration WITH (NOLOCK) 
		         WHERE  exp_code in ('ICFM') 
                 and month(exp_expirationdate) =  month(@DateStart) 
                 and year(exp_expirationdate) =   year(@DateStart) 
              
              
END
ELSE IF @modo in ('REVISADAS')
BEGIN

  INSERT INTO #Inspec

   Select 
            Unidad = exp_id,
            FechaProgramadas = exp_expirationdate ,
            Descripcion = exp_description,
            Completada = exp_completed,
            FechaCompletada = exp_compldate,
            TipoUnidad = exp_idtype,
            Proyecto = (case when exp_idtype = 'TRL' then (Select trl_type3 from trailerprofile where trl_number = exp_id) 
                             when exp_idtype = 'TRC' then (Select trc_type3 from tractorprofile where trc_number = exp_id)  END)
    
		         FROM expiration WITH (NOLOCK) 
		         WHERE  exp_code in ('ICFM') and exp_completed = 'Y'
                 and month(exp_expirationdate) =  month(@DateStart) 
                 and year(exp_expirationdate) =   year(@DateStart) 
                 and day(exp_expirationdate) =   day(@DateStart) 

END

ELSE IF @modo in ('REVISADAS ACUM')
BEGIN

  INSERT INTO #Inspec

   Select 
            Unidad = exp_id,
            FechaProgramadas = exp_expirationdate ,
            Descripcion = exp_description,
            Completada = exp_completed,
            FechaCompletada = exp_compldate,
            TipoUnidad = exp_idtype,
            Proyecto = (case when exp_idtype = 'TRL' then (Select trl_type3 from trailerprofile where trl_number = exp_id) 
                             when exp_idtype = 'TRC' then (Select trc_type3 from tractorprofile where trc_number = exp_id)  END)
    
		         FROM expiration WITH (NOLOCK) 
		         WHERE  exp_code in ('ICFM')  and exp_completed = 'Y'
                 and month(exp_expirationdate) =  month(@DateStart) 
                 and year(exp_expirationdate) =   year(@DateStart) 
       
END

-------------------------CALCULO DEL NUMERADOR------------------------------------------------------------------------------------------------------------------


If @modo in ('TOTAL')
   BEGIN   
     SELECT @ThisCount =  (Select  count(unidad)  from #Inspec)  
   END
If @modo in ('REVISADAS','REVISADAS ACUM')
   BEGIN   
     SELECT @ThisCount =  (Select  count(unidad)  from #Inspec where completada = 'Y')  
   END
--CUENTA DE UNIDADES AUN EN CORRALON
ELSE IF @modo = 'POR REVISAR'
   BEGIN
     SELECT @ThisCount = (Select  count(unidad)  from #Inspec where completada <> 'Y')
   END
--CUENTA DE UNIDADES LIBERADAS EN EL AÑO
ELSE IF @modo = 'PORCENTAJE'
   BEGIN
           SELECT @ThisCount =  (Select  count(unidad)  from #Inspec where completada = 'Y')  
   END

-------------------------CALCULO DEL DENOMINADOR------------------------------------------------------------------------------------------------------------------
If @modo in ('TOTAL')
   BEGIN   
     SELECT @ThisTotal =  1  
   END
 if @modo in ('REVISADAS','POR REVISAR','REVISADAS ACUM') 
    BEGIN
        SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
    END
 ELSE IF  @modo = 'PORCENTAJE'
 BEGIN
        SELECT @ThisTotal = (select count(unidad) from  #Inspec)
    END


------------------------CALCULO DEL RESULTADO TOTAL---------------------------------------------------------------------------------------------------------------------

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

  
-------DETALLE REVISADAS/ POR REVISAR A NIVEL DE TRACTOR------------------------------------------------------------


	IF (@ShowDetail=1)  and  @modo in ('REVISADAS','REVISADAS ACUM')

	BEGIN
	  select Unidad,
            Placas = (Select trc_licnum from tractorprofile where trc_number = Unidad),
            Terminacion = substring( replace(isnull((Select trc_licnum from tractorprofile where trc_number = Unidad),'NA'),'','NA'),3,1),  
            Proyecto = Proyecto, 
            FechaProgramada ,
            Descripcion,
            FechaCompletada 
      from #Inspec   
     where Completada = 'Y'
     and tipounidad = 'TRC'
    order by Proyecto, Unidad
	END
  

	IF (@ShowDetail=1)  and @modo = 'POR REVISAR'
	BEGIN
	  select Unidad,
            Placas = (Select trc_licnum from tractorprofile where trc_number = Unidad), 
            Terminacion = substring( replace(isnull((Select trc_licnum from tractorprofile where trc_number = Unidad),'NA'),'','NA'),3,1), 
            Proyecto = Proyecto, 
            FechaProgramada,
            Descripcion
      from #Inspec
    where Completada <> 'Y'
     and tipounidad = 'TRC'
    order by Proyecto, Unidad
	END

IF (@ShowDetail=1)  and @modo = 'TOTAL'
	BEGIN
	  select Unidad,
            Placas = (Select trc_licnum from tractorprofile where trc_number = Unidad), 
            Terminacion = substring( replace(isnull((Select trc_licnum from tractorprofile where trc_number = Unidad),'NA'),'','NA'),3,1), 
            Proyecto = Proyecto, 
            FechaProgramada,
            Descripcion
      from #Inspec
     where tipounidad = 'TRC'
    order by Proyecto, Unidad
	END

	IF (@ShowDetail=1)  and @modo = 'PORCENTAJE'

	BEGIN
	  select  
            Proyecto =  Proyecto,
           TractoresRevisados =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRC' and pcompletada = 'Y'  and  PProyecto = proyecto ),
           TractoresPorRevisar =  (Select count(PUnidad) from #PInspec where ptipoUnidad = 'TRC' and pcompletada = 'N'  and  PProyecto = proyecto ),
           TractoresTotales =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRC' and PProyecto = proyecto ),
           AvanceTractores = dbo.fnc_TMWRN_FormatNumbers((Select count(PUnidad) from #PInspec  where pcompletada = 'Y'  and ptipoUnidad = 'TRC' and PProyecto = proyecto   ) / replace((Select count(PUnidad) from #PInspec where  ptipoUnidad = 'TRC' and PProyecto = proyecto),0,1),2) + '%'
      from #Inspec   
     --where Completada = 'Y'
     group by Proyecto
	END



 -------DETALLE REVISADAS/ POR REVISAR A NIVEL DE REMOLQUE------------------------------------------------------------



	IF (@ShowDetail=2) and @modo in ('REVISADAS','REVISADAS ACUM')

	BEGIN
	  select Unidad,
            Placas = replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'), 
            Terminacion = substring( replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'),3,1), 
            Proyecto = Proyecto, 
            FechaProgramada ,
            Descripcion,
            FechaCompletada 
      from #Inspec   
     where Completada = 'Y'
     and tipounidad = 'TRL'
    order by Proyecto, Unidad
	END
  

	IF (@ShowDetail=2)  and @modo = 'POR REVISAR'
	BEGIN
	  select Unidad,      
      Placas = replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'), 
      Terminacion = substring( replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'),3,1), 
      Proyecto = Proyecto, 
      FechaProgramada,
      Descripcion
      from #Inspec
    where Completada <> 'Y'
     and tipounidad = 'TRL'
    order by Proyecto, Unidad
	END

	IF (@ShowDetail=2)  and @modo = 'TOTAL'
	BEGIN
	  select Unidad,      
      Placas = replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'), 
      Terminacion = substring( replace(isnull((Select trl_licnum from trailerprofile where trl_number = Unidad),'NA'),'','NA'),3,1), 
      Proyecto = Proyecto, 
      FechaProgramada,
      Descripcion
      from #Inspec
    where  tipounidad = 'TRL'
    order by Proyecto, Unidad
	END

	IF (@ShowDetail=2)  and @modo = 'PORCENTAJE'

	BEGIN
	  select  
            Proyecto =  Proyecto, 
            RemolquesRevisados =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRL' and pcompletada = 'Y'  and  PProyecto = proyecto ),
            RemolquesPorRevisar =  (Select count(PUnidad) from #PInspec where ptipoUnidad = 'TRL' and pcompletada = 'N'  and  PProyecto = proyecto ),
            RemolquesTotales =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRL' and PProyecto = proyecto   ),
            AvanceRemolques = dbo.fnc_TMWRN_FormatNumbers((Select count(PUnidad) from #PInspec  where pcompletada = 'Y'  and ptipoUnidad = 'TRL' and PProyecto = proyecto   ) / replace((Select count(PUnidad) from #PInspec where  ptipoUnidad = 'TRL' and PProyecto = proyecto),0,1),2) + '%'
      from #Inspec   
     --where Completada = 'Y'
     group by Proyecto
	END


 -------DETALLE  POR PROYECTO------------------------------------------------------------


	IF (@ShowDetail=3)  and @modo = 'PORCENTAJE'

	BEGIN
	  select  
            Proyecto =  Proyecto, 
            TractoresRevisados =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRC' and pcompletada = 'Y' and PProyecto = Proyecto  ),
            RemolquesRevisado  =  (Select count(PUnidad) from #PInspec  where ptipoUnidad = 'TRL' and pcompletada = 'Y' and  PProyecto = Proyecto   ),
            TractoresTotales =  (Select count(PUnidad) from #PInspec where ptipoUnidad = 'TRC' and PProyecto = Proyecto ),
            RemolquesTotales =  (Select count(PUnidad) from #PInspec where ptipoUnidad = 'TRL' and PProyecto = Proyecto )
            --AvanceTotal  = dbo.fnc_TMWRN_FormatNumbers((Select count(Unidad) from #Inspec where completada = 'Y' ) / (Select count(Unidad) from #Inspec),2) + '%'
      from #Inspec   
     --where Completada = 'Y'
    group by Proyecto
	END




	IF (@ShowDetail=3)  and @modo = 'POR REVISAR'

	BEGIN
	  select  
            Proyecto =  Proyecto, 
            TractoresPorRevisar=  (Select count(PUnidad) from #pInspec where ptipoUnidad = 'TRC' and pcompletada = 'N' and pproyecto = proyecto ),
            RemolquesPorRevisar =  (Select count(pUnidad) from #pInspec where ptipoUnidad = 'TRL' and pcompletada = 'N' and pproyecto = proyecto  )
      from #Inspec   
     --where Completada = 'Y'
     group by Proyecto
	END


	IF (@ShowDetail=3) and @modo in ('REVISADAS','REVISADAS ACUM')

	BEGIN
	  select  
            Proyecto =  Proyecto, 
            TractoresRevisados=  (Select count(PUnidad) from #pInspec where ptipoUnidad = 'TRC' and pcompletada = 'Y'  and pproyecto = proyecto ),
            RemolquesRevisados =  (Select count(PUnidad) from #pInspec where ptipoUnidad = 'TRL' and pcompletada = 'Y' and pproyecto = proyecto  )
      from #Inspec   
     --where Completada = 'Y'
     group by Proyecto
	END
GO
