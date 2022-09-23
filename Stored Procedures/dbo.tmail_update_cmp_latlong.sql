SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[tmail_update_cmp_latlong] ( @cmpid varchar(25), @stpnumber int, @pnewlat varchar(20), @pnewlong varchar(20))
as

/***
   In:
       @cmpid:		If not available, supply @stpnumber.
       @stpnumber:	Only used if cmpid = ''
       @pnewlat:	Latitude in degrees.
       @pnewlong:	Longitude in degrees, with reverse sign.
  						Sign reversed, because that is how it is stored in TotalMail tblMessages.
                        Parm is typically filled from business rule LAT, which takes the value
  							of tblMessages.Longitude.
***/

exec dbo.tmail_update_cmp_latlong2 @cmpid, @stpnumber, @pnewlat, @pnewlong, '0'

GO
GRANT EXECUTE ON  [dbo].[tmail_update_cmp_latlong] TO [public]
GO
