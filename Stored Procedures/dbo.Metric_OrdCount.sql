SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_OrdCount] 
(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	--Additional/Optional Parameters

	@OnlyStatus varchar(128) ='',
	@OnlyCompanies varchar(128)='',   --SAEMAZ,SAEMAN,SAEGDL,SAEJUAPA,SAEJUAAL,SAETOL,SAETIJ,SAEHERMO
	@OnlyBilltoIDList	varchar(128) =''
)

AS

SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Carrier,2:Tipo Zona,3:ProyectoGP,4:Tipo Equipo



	Set @OnlyStatus= ',' + ISNULL(@OnlyStatus,'') + ','
	Set @OnlyCompanies= ',' + ISNULL(@OnlyCompanies,'') + ','	
	Set @OnlyBilltoIDList= ',' + ISNULL(@OnlyBilltoIDList,'') + ','

	DECLARE @NUMBER_OF_COMPARES int

	CREATE TABLE #orders (ord_Shipper varchar(30) , ord_hdrnumber varchar(10) )

	DELETE #orders

	


--SELECT PRINCIPAL DE LA METRICA CALCULO NUMERADOR E INFO PARA DESPLIEGUE DEL DETALLE----------------------------------------------------------------------


INSERT INTO #orders (ord_Shipper, ord_hdrnumber)

    select ord_shipper,ord_hdrnumber
	FROM orderheader 
	WHERE (ord_startdate between @DateStart and @DateEnd)
	    AND (@OnlyStatus =',,' or CHARINDEX(',' + RTRIM( ord_status) + ',', @OnlyStatus) >0)
		AND (@OnlyCompanies =',,' or CHARINDEX(',' + RTRIM( ord_shipper ) + ',', @OnlyCompanies) >0)
		AND (@OnlyBilltoIDList =',,' or CHARINDEX(',' + RTRIM( ord_billto ) + ',', @OnlyBilltoIDList) >0)


INSERT INTO #orders (ord_Shipper, ord_hdrnumber)

    select ord_consignee,ord_hdrnumber
	FROM orderheader 
	WHERE (ord_startdate between @DateStart and @DateEnd)
	    AND (@OnlyStatus =',,' or CHARINDEX(',' + RTRIM( ord_status) + ',', @OnlyStatus) >0)
		AND (@OnlyCompanies =',,' or CHARINDEX(',' + RTRIM( ord_consignee ) + ',', @OnlyCompanies) >0)
		AND (@OnlyBilltoIDList =',,' or CHARINDEX(',' + RTRIM( ord_billto ) + ',', @OnlyBilltoIDList) >0)
		AND ord_hdrnumber not in (select ord_hdrnumber from #orders)



---CALCULO DEL RESULTADO DE LA METRICA-------------------------------------------------------------------------------------------------------------------

	SELECT @ThisCount =  (select COUNT(*) FROM #orders)
	SELECT @ThisTotal = CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

-----DESPLIEGUE DE LOS DETALLES--------------------------------------------------------------------------------------------------------------------------


---- 1 a nivel de carrier-----------------------------------------------------

	IF @ShowDetail = 1
	BEGIN
		SELECT ord_carrier as Carrier, count(ord_hdrnumber) as Ordenes from orderheader (nolock)
		where ord_hdrnumber in (select ord_hdrnumber from #orders)
		group by ord_carrier

    END
---- 2 a nivel de  tipo de viaje-----------------------------------------------------

	IF @ShowDetail = 2
	BEGIN
		SELECT ord_trl_type3 as TipoZona, count(ord_hdrnumber) as Ordenes from orderheader (nolock)
		where ord_hdrnumber in (select ord_hdrnumber from #orders)
		group by ord_trl_type3

	END

---- 3 a nivel de ProyectoSIAB-----------------------------------------------------

	IF @ShowDetail = 3
	BEGIN
		SELECT substring(ord_refnum,0,7) as ProyectoGP, count(ord_hdrnumber) as Ordenes from orderheader (nolock)
		where ord_hdrnumber in (select ord_hdrnumber from #orders)
		group by substring(ord_refnum,0,7)

	END

---- 4 a nivel de tipo  equipo req-----------------------------------------------------

	IF @ShowDetail = 4
	BEGIN
		SELECT ord_description as Equipo, count(ord_hdrnumber) as Ordenes from orderheader (nolock)
		where ord_hdrnumber in (select ord_hdrnumber from #orders)
		group by ord_description

	END



	--select ord_trl_type2, ord_trl_type3, ord_trl_type4,* from orderheader where ord_billto = 'SAE'
GO
