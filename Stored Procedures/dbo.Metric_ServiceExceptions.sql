SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




--exec Metric_ServiceExceptions
--EXEC [Metric_ServiceExceptions] 1,1,1,'2012-12-01','2012-12-31', 1, 1,'SEN,INT,DED,ESP,FUL','NO','NO'

CREATE PROCEDURE [dbo].[Metric_ServiceExceptions] (
	--DECLARACION PARAMETROS ESTANDAR DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--DECLARACION PARAMETROS ESPECIFICOS DE LA METRICA

	  @division Varchar(255) = '',  --     ,DED,ESP,SEN,ABI,INT,FUL
      @OnlyRevType1List varchar(255) = '', 
	  @OnlyRevType2List varchar(255) = '', 
	  @OnlyTrcType2List varchar(255) = '', 
      @noproyecto varchar(255) = ''  --    INCLUIR LOS PROYECTOS QUE SE DESEAN MOSTRAR
        
)
AS
	SET NOCOUNT ON  -- PTS46367

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Orden,2:División


	--INICIALIZACION DE LOS PARAMETROS DE LA METRICA LE AGREGAMOS LAS COMAS PARA HACER EL CHARINDEX POSTERIORMENTE
	Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','
    Set   @OnlyRevType1List = ',' + ISNULL(  @OnlyRevType1List ,'') + ','
	Set   @OnlyRevType2List = ',' + ISNULL(  @OnlyRevType2List ,'') + ','
	Set   @OnlyTrcType2List = ',' + ISNULL(  @OnlyTrcType2List ,'') + ','

	-- CREAMOS LA TABLA TEMPORAL EN LA CUAL DEPOSITAREMOS LOS DATOS
	CREATE TABLE #ServiceException (sxn_ord_hrdnumber int, sxn_expdate datetime, sxn_expcode varchar(6), sxn_description varchar(255), sxn_action_received_desc varchar(255), 
								ord_originregion1 varchar(6), ord_originpoint varchar(8), ord_destregion1 varchar(6), ord_destpoint varchar (8), sxn_cmp_id varchar(150),sxn_affectspay char(1), ord_revtype4 varchar(255), ord_revtype3 varchar (255)
								)

	-- INICIALIZAMOS LA TABLA TEMPORAL CON LOS DATOS RECABADOS DEL SELECT CON EL WHERE QUE FILTRA LOS REVTYPE DESEADOS
	


if @division <> ',NO,' and @OnlyRevType1List = ',NO,'   and @OnlyRevType2List = ',NO,'  and @noproyecto = ',NO,'
begin
print 'Condicion division'
print @division
print @DateStart
print @DateEnd

INSERT INTO #ServiceException
	
SELECT  s.sxn_ord_hdrnumber, s.sxn_expdate,  s.sxn_expcode, s.sxn_description,  sxn_action_received_desc, o.ord_originregion1,
  o.ord_originpoint,o.ord_destregion1, o.ord_destpoint ,sxn_cmp_id, sxn_affectspay, o.ord_revtype4, o.ord_revtype3
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
	WHERE  s.sxn_expdate >= @DateStart AND s.sxn_expdate < @DateEnd and
		s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	    AND (@DIVISION =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype4) + ',', @division) > 0)
		
end

else if @noproyecto = ',NO,' and @OnlyRevType1List <> ',NO,'  and @OnlyRevType2List = ',NO,' 
   begin
print 'Condicion div+kam'
print @division
print @OnlyRevType1List
print @DateStart
print @DateEnd

INSERT INTO #ServiceException
	
SELECT  s.sxn_ord_hdrnumber, s.sxn_expdate,  s.sxn_expcode, s.sxn_description,  sxn_action_received_desc, o.ord_originregion1,
  o.ord_originpoint,o.ord_destregion1, o.ord_destpoint ,sxn_cmp_id, sxn_affectspay, o.ord_revtype4, o.ord_revtype3
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
	WHERE s.sxn_expdate >= @DateStart AND s.sxn_expdate < @DateEnd
		AND s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	        AND (@DIVISION =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype4) + ',', @division) > 0)
			AND (@OnlyRevType1List =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype1) + ',', @OnlyRevType1List) > 0)
end         
 
else if @noproyecto = ',NO,' and @OnlyRevType1List = ',NO,'  and @OnlyRevType2List <> ',NO,' 
   begin
print 'Condicion div+kam'
print @division
print @OnlyRevType1List
print @DateStart
print @DateEnd

INSERT INTO #ServiceException
	
SELECT  s.sxn_ord_hdrnumber, s.sxn_expdate,  s.sxn_expcode, s.sxn_description,  sxn_action_received_desc, o.ord_originregion1,
  o.ord_originpoint,o.ord_destregion1, o.ord_destpoint ,sxn_cmp_id, sxn_affectspay, o.ord_revtype4, o.ord_revtype3
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
	WHERE s.sxn_expdate >= @DateStart AND s.sxn_expdate < @DateEnd
		AND s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	        AND (@DIVISION =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype4) + ',', @division) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype2) + ',', @OnlyRevType2List) > 0)
end         


else if @noproyecto <> ',NO,' and @OnlyRevType1List = ',NO,'  and @OnlyRevType2List = ',NO,' 
   begin
print 'Condicion div+proy'
print @division
print @noproyecto
print @DateStart
print @DateEnd

INSERT INTO #ServiceException
	
SELECT  s.sxn_ord_hdrnumber, s.sxn_expdate,  s.sxn_expcode, s.sxn_description,  sxn_action_received_desc, o.ord_originregion1,
  o.ord_originpoint,o.ord_destregion1, o.ord_destpoint ,sxn_cmp_id, sxn_affectspay, o.ord_revtype4, o.ord_revtype3
	FROM serviceexception s with (NOLOCK), orderheader o with (NOLOCK)
	WHERE s.sxn_expdate >= @DateStart AND s.sxn_expdate < @DateEnd
		AND s.sxn_ord_hdrnumber = o.ord_hdrnumber 
	        AND (@DIVISION =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype4) + ',', @division) > 0)
			AND (@noproyecto =',,' or CHARINDEX(',' + RTRIM(o.ord_revtype3) + ',', @noproyecto) > 0)
end         
 

 if @OnlyTrcType2List <> 'N0' 
   begin
    delete  #ServiceException
    where  (select ord_tractor from orderheader orr (nolock)  where orr.ord_hdrnumber = #ServiceException.sxn_ord_hrdnumber) 
	not in (select trc_number from tractorprofile nolock where (@OnlyTrcType2List =',,' or CHARINDEX(',' + RTRIM(trc_type2) + ',', @OnlyTrcType2List) > 0))
   end


--select * from serviceexception


  -- PASAMOS LOS VALORES AL NUMERADOR Y AL DENOMINADOR 

	
	SELECT @ThisCount = CONVERT(decimal(20, 5), COUNT(*)) FROM #ServiceException 


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END

print '------------------------------'
print 'Fechas despues del datediff'
print ' FECHA INICIO  ' + cast(@DateStart as varchar)
print ' FECHA FIN  ' + cast( @DateEnd as varchar)
print ' DIIVSION  ' +@division
print ' KAM ' +@OnlyRevType1List
print ' PROY ' +@noproyecto
print ' Total ' + cast(@ThisCount as varchar)
print '------------------------------'

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

print 'Resultado ' + cast(@Result as varchar)
print '------------------------------'

--CONSULTA PARA MOSTRA LOS DETALLES DE LA MEWTRICA EN LA TABLA

	IF (@ShowDetail=1)
	BEGIN
		Select Orden = sxn_ord_hrdnumber, Division = ord_revtype4 , Cliente = sxn_cmp_id, Fecha = sxn_expdate, Responsable = sxn_expcode, Descripcion = sxn_description, 
				Origen= ord_originpoint, Destino = ord_destpoint
		From #ServiceException
		Order by sxn_ord_hrdnumber
	END

	ELSE IF (@ShowDetail=2)
	BEGIN
		Select Division = ord_revtype4, count(sxn_ord_hrdnumber) as Ordenes
		From #ServiceException
		Group by ord_revtype4
		order by ord_revtype4
	END





GO
GRANT EXECUTE ON  [dbo].[Metric_ServiceExceptions] TO [public]
GO
