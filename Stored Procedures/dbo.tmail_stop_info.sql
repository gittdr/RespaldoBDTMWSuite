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
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_stop_info] (@stop_nbr varchar(12))

AS

SET NOCOUNT ON 

DECLARE @stop int,
	@success tinyint,
	@move int,
	@order int,
	@sT_1 varchar(200) 		-- Translation String

IF NOT ISNULL(@stop_nbr,'') = ''  
	SELECT @stop = CONVERT(int, @stop_nbr)
ELSE 
	SELECT @stop = -1

IF @stop = -1
  BEGIN	
	SELECT @sT_1 = '{TMWERR:1039} Stop Info: Not enough information to determine stop.'
--	EXEC tm_t_sp @sT_1 out, 1, ''
	RAISERROR (@sT_1,16,-1)
	RETURN 1
  END
ELSE
    EXEC tmail_stop_info2 @stop_nbr
GO
GRANT EXECUTE ON  [dbo].[tmail_stop_info] TO [public]
GO
