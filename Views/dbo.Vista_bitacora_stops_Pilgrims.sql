SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[Vista_bitacora_stops_Pilgrims]

as


select 
(select cty_nmstct from city where cty_code = stp_city) as ciudad, stp_arrivaldate, stp_departuredate,lgh_number from stops 
GO
