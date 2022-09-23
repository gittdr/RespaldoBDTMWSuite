SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* tmail_commodity **************************************************************
** Pulls all commodities for a specified stop number
** Created:		Matthew Zerefos  12/14/99
** 02/26/04 MZ Added length, width & height fields		
** 03/31/04 MZ Made call to tmail_commodity2
** 8/26/04 jgf Changed 2nd parm (frgt detail seq) to -5 for ALL. PTS 24343.
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_commodity] @stop_nbr_parm varchar(20)

AS

EXEC dbo.tmail_commodity2 @stop_nbr_parm, '-5'
GO
GRANT EXECUTE ON  [dbo].[tmail_commodity] TO [public]
GO
