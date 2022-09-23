SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* tmail_stop_info **************************************************************
** Pulls information about a specific stop
** Created:		Matthew Zerefos  05/01/00		

	*** Order for stop determination
	1. Stop number
	2. Move number, stop sequence & tractor
	3. Order number, stop sequence & tractor
	4. Stop sequence and tractor (STD leg first, then oldest PLN or DSP)
	5. First stop not actualized for this tractor (STD leg first, then oldest PLN or DSP)

* REVISIONS *
* 01/19/06 MIZ Added StopState view field (PTS31401).
* 01/23/06 MIZ Added StopStatus and StopDepartStatus view fields (PTS31470)
* 05/31/06 TSA Added UnloadPayType (PTS31505).
* 08/07/06 DWG Called tmail_Stop_Info3
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_stop_info2] (@stop_nbr varchar(12))

AS

EXEC tmail_stop_info3 @stop_nbr, "0", "0", "0"
GO
GRANT EXECUTE ON  [dbo].[tmail_stop_info2] TO [public]
GO
