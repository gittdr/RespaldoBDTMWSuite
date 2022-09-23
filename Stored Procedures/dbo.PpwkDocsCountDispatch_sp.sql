SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[PpwkDocsCountDispatch_sp]
( @ord_hdrnumber  INT
, @docsrequired   INT OUTPUT
, @docsreceived   INT OUTPUT
) AS

/**
 * 
 * NAME:
 * dbo.PpwkDocsCountDispatch_sp
 *
 * TYPE:
 * Stored proc
 *
 * DESCRIPTION:
 * Returns a count of required paperwork docs not yet received in output variable
 * and fills out a count of docs required and docs received
 *
 * RETURNS:
 * NA
 *
 * RESULT SETS: 
 * NA
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber INT
 * 002 - @docsrequired  INT OUTPUT
 * 003 - @docsreceived  INT OUTPUT
 *
 * REVISION HISTORY:
 * 07/20/11 SPN PTS51905 - Initial Version created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @PPWKMode       VARCHAR(15)
   DECLARE @ll_mov_number  INT

   DECLARE @ppwk TABLE
   ( bdt_doctype     VARCHAR(6)  NULL
   , pw_received     CHAR(1)     NULL
   , ord_hdrnumber   INT         NULL
   )

   SELECT @PPWKMode = gi_string1
     FROM generalinfo
    WHERE gi_name = 'PaperWorkMode'
   SELECT @PPWKMode = IsNull(@PPWKMode,'A')

   SELECT @ll_mov_number = mov_number
     FROM orderheader
    WHERE ord_hdrnumber = @ord_hdrnumber

   --Get Required Paperwork
   IF @PPWKMode = 'A'
      INSERT INTO @ppwk (bdt_doctype, pw_received, ord_hdrnumber)
      SELECT l.abbr           AS bdt_doctype
           , 'N'              AS pw_received
           , o.ord_hdrnumber  AS ord_hdrnumber
        FROM labelfile l
           , (SELECT ord_hdrnumber
                FROM orderheader
               WHERE mov_number = @ll_mov_number
             ) o
       WHERE l.labeldefinition = 'PaperWork'
         AND IsNull(l.retired,'N') = 'N'
   ELSE
      INSERT INTO @ppwk (bdt_doctype, pw_received, ord_hdrnumber)
      SELECT bdt.bdt_doctype  AS bdt_doctype
           , 'N'              AS pw_received
           , o.ord_hdrnumber  AS ord_hdrnumber
        FROM billdoctypes bdt
           , (SELECT DISTINCT 
                     ord_hdrnumber
                   , ord_billto
                FROM orderheader
               WHERE mov_number = @ll_mov_number
             ) o
       WHERE o.ord_billto = bdt.cmp_id
         AND IsNull(bdt.bdt_required_for_dispatch,'N') = 'Y'

   --Get Received Paperwork
   UPDATE @ppwk
      SET pw_received = 'Y'
     FROM @ppwk p
     JOIN paperwork ppwk ON p.ord_hdrnumber = ppwk.ord_hdrnumber
                        AND p.bdt_doctype   = ppwk.abbr
                        AND 'Y'             = ppwk.pw_received

   --Get counts
   SELECT @docsrequired = COUNT(1) FROM @ppwk
   SELECT @docsreceived = COUNT(1) FROM @ppwk WHERE pw_received = 'Y'

   If (SELECT gi_string1
         FROM generalinfo
        WHERE gi_name = 'PaperworkMarkedYes'
      ) = 'ONE' AND @docsreceived > 0
   BEGIN
      SELECT @docsreceived = @docsrequired
   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[PpwkDocsCountDispatch_sp] TO [public]
GO
