SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_ConvoyTiempoLectura] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @Treshold int  = 10,    
    @Division  varchar(20)  = 'TODAS',     --ABI,DED,ESP
	@Proyecto varchar(20) = 'TODOS'


)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Flota,2:Usuario,3:Detalle


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #CTL
    (msgid int,
	 subject varchar(max),
	 msg varchar(max),
	 dtsent datetime,
     fechaleido datetime,
     minenleer int,
     leidopor varchar(200),
	 enviadopor varchar(200),
	 enviadoa varchar(200),
	 proyecto varchar(20),
	 division varchar(20),
	 
	  )

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #CTL

		select 
		SN,
		subject,
		[dbo].[RTF2Text](Contents) as msg,
		dtsent,
		DTRead as  FechaLeido,
		datediff(mi,DTsent,Dtread) as MinEnLeer,
		(select Readbyname from tblMsgShareData s (nolock) where s.origmsgsn = t.OrigMsgSN) as LeidoPor,
		fromname,
		deliverto,
		((select mpp_type3 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as proyecto,
	    ((select mpp_type4 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as division
		from tblMessages  t
		where DeliverToType = 3
		and(select Readbyname from tblMsgShareData s (nolock) where s.origmsgsn = t.OrigMsgSN)  is not null
		and (datediff(mi,DTSent,Dtread)   > 10
		or (DTRead is null or DTRead = ''))
		and folder  in (373)
		and (subject like 'Macro%' or subject like 'Mensaje Libre%'or subject like '%Parada en viaje%' or Subject like 'SOLICITUD DE DESCANSO' or subject like '%REPORTAR%')


		 and DTSent between @DateStart and @DateEnd
		order by MinENLeer desc


		
	  if (@Division <> 'TODAS') 
	    BEGIN
	      delete  #CTL where Division  <> @Division
		END


	
		if (@Proyecto <> 'TODOS') 
		BEGIN 
		 delete #CTL where Proyecto <> @Proyecto
		 END
		

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select count(*)  from #CTL)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Unidades  revisadas por dia





IF (@ShowDetail=1) 
	BEGIN
		Select enviadoa as Flota,count(*) as Mensajes
          from #CTL
		  group by enviadoa
		  order by count(*) desc
      
      
	END

	IF (@ShowDetail=2) 
	BEGIN
		Select LeidoPor,count(*) as Mensajes
          from #CTL
		  group by LeidoPor
		  order by count(*) desc
      
    
	END


IF (@ShowDetail=3) 
	BEGIN
		Select 
      *
          from #CTL
      
      
	END

GO
