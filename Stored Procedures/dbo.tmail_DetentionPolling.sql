SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_DetentionPolling] @HrsToCheckDetention int, @MakeNextStopCheck char(1)

AS
/**
 * pts 73535
 * HMA 11/19/13
 * NAME:
 * tmail_DetentionPollingUpdate.sql
 *
 * TYPE:
 * script
 *
 * DESCRIPTION:
 * This script Updates [tmail_DetentionPolling] and then to preserve backwards compatibility
 * will rename updated proc [tmail_DetentionPolling2] and have a new [tmail_DetentionPolling] call
 * [tmail_DetentionPolling2]
 *
 * 08/09/2013    - PTS67826 - HMA tmail_DetentionPolling now just calls tmail_DetentionPolling2 WITHOUT 3rd param
 * 12/16/2013.01 - PTS74187 - vjh chicking in HMA 67826/73535
 **/
/**
 *
 * NAME:
 * dbo.tmail_DetentionPolling
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure checks each open stop to see if and actions need to be
 * taken for the detention alerting system.
 *
 **/
Set nocount on
exec dbo.tmail_DetentionPolling2 @HrsToCheckDetention, @MakeNextStopCheck ,'default' 
GO
GRANT EXECUTE ON  [dbo].[tmail_DetentionPolling] TO [public]
GO
