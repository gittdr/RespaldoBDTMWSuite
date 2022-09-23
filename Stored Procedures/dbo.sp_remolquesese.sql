SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE proc  [dbo].[sp_remolquesese] 

as



;WITH XMLNAMESPACES (
                     'http://schemas.datacontract.org/2004/07/Nervia.Tdi.GenericWcf.Models' as ner,
					 'http://tempuri.org/' as tem,
					 'http://schemas.xmlsoap.org/soap/envelope/' as soapenv)

Select 

[soapenv:Header] = '',
[soapenv:Body] =
---------------------------------------------------------------------------------------------------------------------------------------------------------
	(SELECT 

	  
		[tem:providerId] = 25,
		[tem:providerPassword] = 'C8cx;s:O@1a',
		[tem:vehiclePositions] =
		(
		SELECT 
		
		[ner:DateTime] = GETUTCDATE(),
		[ner:Latitude]=cast(isnull(trl_gps_latitude / 3600.00 ,'19.2333333') as varchar(20)),
		[ner:Longitude]= cast(isnull(-1* (trl_gps_longitude/ 3600.00),'-97.7494444') as varchar(20)),
		[ner:PositionDateTime] = convert(varchar,(isnull(DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), trl_gps_date),GETUTCDATE())),126)  ,
		[ner:VehicleId] = trl_number

		from trailerprofile
		where trl_fleet = '13'
		FOR XML RAW ('ner:DtoGenericVehiclePosition') ,ELEMENTS, type)
		

	FOR XML  RAW ('tem:SetVehiclePositions'), ELEMENTS, type)

----------------------------------------------------------------------------------------------------------------------------------------------------------
FOR XML  RAW ('soapenv:Envelope'), ELEMENTS, type



GO
