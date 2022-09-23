SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[reset_loadrequirements_sp] (@movnumber int)       
AS

/*
*     PTS 41178 - DJM - 4/7/08 - Add Load Requirements for Bill To companies
*/

--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
set transaction isolation level read uncommitted
--end 62031

-- Don't deal with empty moves
IF ( SELECT MAX( ord_hdrnumber) FROM stops WHERE mov_number = @movnumber) = 0 RETURN

-- Create a list of all default requirements which are tagged as inactive for this move
DECLARE @inactive TABLE (
      ord_hdrnumber     INTEGER           NOT NULL,
      lrq_sequence      INTEGER           NOT NULL,
      lrq_equip_type    VARCHAR(6)  NOT NULL,
      lrq_type          VARCHAR(6)  NOT NULL,
      lrq_not                 CHAR(1)     NOT NULL,
      lrq_manditory     CHAR(1)     NOT NULL,
      lrq_quantity      INT         NULL,
      stp_number        INTEGER           NULL,
      fgt_number        INTEGER           NULL,
      cmp_id                  VARCHAR(8)  NULL,
      def_id_type       VARCHAR(6)  NULL,
      lgh_number        INTEGER           NULL,
      mov_number        INTEGER           NULL,
      lrq_default       CHAR(1)           NULL,
      cmd_code          VARCHAR(8)  NULL,
      def_required      CHAR(1)           NULL,
      -- PTS 18488 -- BL (start)
      lrq_expire_date   datetime    NULL)
      -- PTS 18488 -- BL (end)

INSERT INTO @inactive
      SELECT      ord_hdrnumber,
                  lrq_sequence,
            lrq_equip_type,
                  lrq_type,
                  lrq_not,
                  lrq_manditory,
                  lrq_quantity,
                  stp_number,
                  fgt_number,
                  cmp_id,
                  def_id_type,
                  lgh_number,
                  mov_number,
                  lrq_default,
                  cmd_code,
                  def_required,
                  -- PTS 18488 -- BL (start)
                  lrq_expire_date
                  -- PTS 18488 -- BL (end)
        FROM      loadrequirement
      WHERE      mov_number = @movnumber AND
                  lrq_default = 'X'

-- Delete all current default loadrequirements for this move
DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND 
            lrq_default IN ('Y','X')

-- Create a table of company/commoditiy/stop types  on the move
DECLARE @cmpcmdstop TABLE (
      cmp_id            VARCHAR(8)  NOT NULL,
      cmd_code    VARCHAR(8)  NOT NULL,
      stp_type    VARCHAR(6)  NOT NULL,
      stp_billto  VARCHAR(8)  NOT NULL)

INSERT INTO @cmpcmdstop
      SELECT DISTINCT 
                  s.cmp_id,
                  fd.cmd_code, 
                  s.stp_type,
                  (select isnull((select isnull(o.ord_billto, 'UNKNOWN') from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber and s.ord_hdrnumber > 0), 'UNKNOWN')) 
        FROM      stops s, 
                  freightdetail fd
      WHERE      s.stp_number = fd.stp_number AND
                  s.mov_number = @movnumber AND
                  s.stp_type IN ('PUP','DRP') AND
                  ISNULL(s.cmp_id, 'UNKNOWN') <> 'UNKNOWN' AND
                  ISNULL(fd.cmd_code, 'UNKNOWN') <> 'UNKNOWN'


-- Create a table of company and stop types on the move
DECLARE @cmpstop TABLE (
      cmp_id            VARCHAR(8)  NOT NULL,
      stp_type    VARCHAR(6)  NOT NULL)

INSERT INTO @cmpstop
      SELECT DISTINCT 
                  cmp_id, 
                  stp_type
        FROM      stops
      WHERE      mov_number = @movnumber AND
                  stp_type IN ('PUP', 'DRP') AND
                  ISNULL(cmp_id, 'UNKNOWN') <> 'UNKNOWN'

/* Insert a record if an Orders's billto on the Movement matches the cmp_id for a Bill To Load Requirement.       */


-- create a table of commodities  on the order
DECLARE @cmd TABLE (
      cmd_code    VARCHAR(8)  NOT NULL)

INSERT INTO @cmd
      SELECT DISTINCT 
                  fd.cmd_code
        FROM      stops s,
                  freightdetail fd
      WHERE      s.stp_number = fd.stp_number AND
                  s.mov_number = @movnumber AND
                  ISNULL(fd.cmd_code, 'UNKNOWN') <> 'UNKNOWN'

-- PTS #71399, 01/14/2014, Collect all 'BillTo'  companies on this move.
DECLARE @ordersBillTo TABLE ( ord_billto  VARCHAR(8)  NOT NULL)
      
INSERT INTO @ordersBillTo
  SELECT DISTINCT ISNULL(o.ord_billto, 'UNKNOWN') 
  FROM  stops s
  INNER JOIN orderheader o
	 ON (s.ord_hdrnumber = o.ord_hdrnumber) AND (s.ord_hdrnumber > 0)    
  WHERE (s.mov_number = @movnumber)
    AND (s.stp_type IN ('PUP','DRP'))
    AND (ISNULL(s.cmp_id, 'UNKNOWN') <> 'UNKNOWN' )
    
    
DECLARE @lrq TABLE(
      ord_hdrnumber     INTEGER           NOT NULL,
      lrq_sequence      INTEGER           NOT NULL,
      lrq_equip_type    VARCHAR(6)  NOT NULL,
      lrq_type          VARCHAR(6)  NOT NULL,
      lrq_not                 CHAR(1)     NOT NULL,
      lrq_manditory     CHAR(1)     NOT NULL,
      lrq_quantity      INT         NULL,
      stp_number        INTEGER           NULL,
      fgt_number        INTEGER           NULL,
      cmp_id                  VARCHAR(8)  NULL,
      def_id_type       VARCHAR(6)  NULL,
      lgh_number        INTEGER           NULL,
      mov_number        INTEGER           NULL,
      lrq_default       CHAR(1)           NULL,
      cmd_code          VARCHAR(8)  NULL,
      def_required      CHAR(1)           NULL,
      -- PTS 18488 -- BL (start)
      lrq_expire_date         datetime    NULL,
      -- PTS 18488 -- BL (end)
      lrg_cmp_billto    char(1)           NULL,       -- PTS 41178 - DJM
      loadreqdefault_ident                 integer           not null, 
	  lrq_field			varchar(6) null, 
	  lrq_units			varchar(6) null)   

-- Collect product specific default requirements
INSERT INTO @lrq
      SELECT DISTINCT 
                  0,
                  1,
                  lrd.def_equip_type,
                  lrd.def_type,
                  lrd.def_not,
                  lrd.def_manditory,
                  ISNULL(lrd.def_quantity, 0),
                  0,
                  0,
                  ISNULL(lrd.def_id, 'UNKNOWN'),
                  ISNULL(lrd.def_id_type, 'BOTH'),
                  0,
                  @movnumber,   
                  'Y',
                  ISNULL(lrd.def_cmd_id, 'UNKNOWN'),
                  def_required,
                  -- PTS 18488 -- BL (start)
                  def_expire_date,
                  -- PTS 18488 -- BL (end)
                  isNull(def_cmp_billto,'N') def_cmp_billto,                  -- PTS 41178 -DJM
                  lrd.loadreqdefault_ident,                                           -- PTS 62774
				  lrd.def_field, 
				  lrd.def_units
        FROM      loadreqdefault lrd, @cmd cmd
      WHERE      lrd.def_cmd_id = cmd.cmd_code AND
                  lrd.def_id = 'UNKNOWN'
            -- PTS 18488 -- BL (start)
                  and lrd.def_expire_date >= GetDate()
            -- PTS 18488 -- BL (end)
                  and isNull(def_cmp_billto,'N') = 'N'                  -- PTS 41178 -DJM

-- Collect pickup or delivery facility default requirements
INSERT INTO @lrq
      SELECT DISTINCT 
                  0,
                  1,
                  lrd.def_equip_type,
                  lrd.def_type,
                  lrd.def_not,
                  lrd.def_manditory,
                  ISNULL(lrd.def_quantity, 0),
                  0,
                  0,
                  ISNULL(lrd.def_id, 'UNKNOWN'),
                  ISNULL(lrd.def_id_type, 'BOTH'),
                  0,
                  @movnumber,   
                  'Y',
                  ISNULL(lrd.def_cmd_id, 'UNKNOWN'),
                  def_required,
                  -- PTS 18488 -- BL (start)
                  def_expire_date,
                  -- PTS 18488 -- BL (end)
                  isNull(def_cmp_billto,'N') def_cmp_billto,                  -- PTS 41178 -DJM
                  lrd.loadreqdefault_ident,                                     -- PTS 62774  
				  lrd.def_field,
				  lrd.def_units
        FROM      loadreqdefault lrd
        INNER JOIN @cmpstop cmpstop 
			ON (     (lrd.def_id = cmpstop.cmp_id )
			     AND ( (lrd.def_id_type = cmpstop.stp_type) OR (lrd.def_id_type = 'BOTH')) 
			   )
		LEFT JOIN dbo.loadreqdefault_billto lrdb 
			ON (lrd.loadreqdefault_ident = lrdb.loadreqdefault_ident) 
		LEFT JOIN @ordersBillTo obt 
		    ON (lrdb.billTo_id = obt.ord_billto)
        WHERE    (lrd.def_cmd_id = 'UNKNOWN') 
           AND (lrd.def_expire_date >= GETDATE())
           AND (ISNULL(def_cmp_billto,'N') = 'N' )
           AND (    (lrdb.loadreqdefault_ident IS NULL)      ---> PTS #71399, BW, 01/14/2014, Either there is no loadrequirementdefault_billTo child row
                 OR ( (lrdb.loadreqdefault_ident IS NOT NULL) AND (obt.ord_billto IS NOT NULL)) ---> or, if there is one, it has to match billTo company
                )    
        /*                      
        FROM      loadreqdefault lrd, @cmpstop cmpstop
      WHERE      lrd.def_id = cmpstop.cmp_id AND
                  lrd.def_id_type IN (cmpstop.stp_type, 'BOTH') AND
                  lrd.def_cmd_id = 'UNKNOWN'
            -- PTS 18488 -- BL (start)
            and lrd.def_expire_date >= GetDate()
            -- PTS 18488 -- BL (end)
                  and isNull(def_cmp_billto,'N') = 'N'                  -- PTS 41178 -DJM
        */
        
-- Collect pickup or delivery facility default requirements for a company/commodity
INSERT INTO @lrq
      SELECT DISTINCT 
                  0,
                  1,
                  lrd.def_equip_type,
                  lrd.def_type,
                  lrd.def_not,
                  lrd.def_manditory,
                  ISNULL(lrd.def_quantity, 0),
                  0,
                  0,
                  ISNULL(lrd.def_id, 'UNKNOWN'),
                  ISNULL(lrd.def_id_type, 'BOTH'),
                  0,
                  @movnumber,   
                  'Y',
                  ISNULL(lrd.def_cmd_id, 'UNKNOWN'),
                  def_required,
                  -- PTS 18488 -- BL (start)
                  def_expire_date,
                  -- PTS 18488 -- BL (end)
                  isNull(def_cmp_billto,'N') def_cmp_billto,                  -- PTS 41178 -DJM
                  lrd.loadreqdefault_ident,                                     -- PTS 62774                  
				  lrd.def_field, 
				  lrd.def_units
        FROM      loadreqdefault lrd
        INNER JOIN  @cmpcmdstop cmpcmdstop
			ON (     ( (lrd.def_id = cmpcmdstop.cmp_id) OR (lrd.def_id = cmpcmdstop.stp_billto) )
			     AND ( (lrd.def_id_type = cmpcmdstop.stp_type) OR (lrd.def_id_type = 'BOTH')  )
			     AND (lrd.def_cmd_id = cmpcmdstop.cmd_code)
			   )
		LEFT JOIN dbo.loadreqdefault_billto lrdb 
			ON (lrd.loadreqdefault_ident = lrdb.loadreqdefault_ident) 
		LEFT JOIN @ordersBillTo obt 
		    ON (lrdb.billTo_id = obt.ord_billto)
      WHERE   (cmpcmdstop.cmd_code <> 'UNKNOWN')
          AND (lrd.def_expire_date >= GETDATE())
          AND (  (lrdb.loadreqdefault_ident IS NULL)      ---> PTS #71399, BW, 01/15/2014 Either there is no loadrequirementdefault_billTo child row
                 OR ( (lrdb.loadreqdefault_ident IS NOT NULL) AND (obt.ord_billto IS NOT NULL)) ---> or, if there is one, it has to match billTo company
                ) 
    /*                 
        FROM      loadreqdefault lrd, @cmpcmdstop cmpcmdstop
      WHERE      (lrd.def_id = cmpcmdstop.cmp_id OR lrd.def_id = cmpcmdstop.stp_billto) AND
                  lrd.def_id_type IN (cmpcmdstop.stp_type, 'BOTH') AND
                  lrd.def_cmd_id = cmpcmdstop.cmd_code AND
                  cmpcmdstop.cmd_code <> 'UNKNOWN'
                  -- PTS 18488 -- BL (start)
                  and lrd.def_expire_date >= GetDate()
                  -- PTS 18488 -- BL (end)
   */

-- Insert Loadrequirements for Bill To companies where there are Orders with the 
--          required Bill To on the Movement.
INSERT INTO @lrq
      SELECT DISTINCT 
                  0,
                  1,
                  lrd.def_equip_type,
                  lrd.def_type,
                  lrd.def_not,
                  lrd.def_manditory,
                  ISNULL(lrd.def_quantity, 0),
                  0,
                  0,
                  ISNULL(lrd.def_id, 'UNKNOWN'),
                  ISNULL(lrd.def_id_type, 'BOTH'),
                  0,
                  @movnumber,   
                  'Y',
                  ISNULL(lrd.def_cmd_id, 'UNKNOWN'),
                  def_required,
                  -- PTS 18488 -- BL (start)
                  def_expire_date,
                  -- PTS 18488 -- BL (end)
                  isNull(def_cmp_billto,'N') def_cmp_billto,                  -- PTS 41178 -DJM
                  lrd.loadreqdefault_ident,                                     -- PTS 62774                  
				  lrd.def_field,
				  lrd.def_units
        FROM      loadreqdefault lrd
      WHERE      lrd.def_id in (select distinct ord_billto
                                                from orderheader o
                                                where o.mov_number = @movnumber) 
                  -- PTS 18488 -- BL (start)
                  and lrd.def_expire_date >= GetDate()
                  -- PTS 18488 -- BL (end)
                  and isNull(def_cmp_billto,'N') = 'Y'                  -- PTS 41178 -DJM
                  
                  
/* PTS# 71399,  BW, 01/08/2014, The only contribution of this DELETE is to create bug described in the PTS.                  
delete from @lrq 
where loadreqdefault_ident not in (select loadreqdefault_ident from @lrq 
      where loadreqdefault_ident not in (select loadreqdefault_ident from loadreqdefault_billto) 
      or loadreqdefault_ident in (select loadreqdefault_ident from loadreqdefault_billto bt where bt.billto_id in (select stp_billto from @cmpcmdstop)))
*/     

-- Re-tag any deactivated defaults
If (SELECT COUNT(*) FROM @inactive) > 0
      UPDATE      @lrq
         SET      lrq_default = 'X'
        FROM      @inactive inactive, @lrq lrq
      WHERE      inactive.cmp_id = lrq.cmp_id AND
                  inactive.cmd_code = lrq.cmd_code AND
                  inactive.def_id_type = lrq.def_id_type AND
                  inactive.lrq_equip_type = lrq.lrq_equip_type AND
                  inactive.lrq_type = lrq.lrq_type

INSERT INTO loadrequirement(
      ord_hdrnumber, 
      lrq_sequence, 
      lrq_equip_type, 
      lrq_type,
      lrq_not, 
      lrq_manditory, 
      lrq_quantity, 
      stp_number,
      fgt_number, 
      cmp_id, 
      def_id_type, 
      lgh_number, 
      mov_number,
      lrq_default, 
      cmd_code,
      def_required,
      -- PTS 18488 -- BL (start)
      lrq_expire_date,
      -- PTS 18488 -- BL (end)
      def_cmp_billto, 
	  lrq_field,
	  lrq_units)
      SELECT DISTINCT
                  ord_hdrnumber, 
                  lrq_sequence, 
                  lrq_equip_type, 
                  lrq_type,
                  lrq_not, 
                  lrq_manditory, 
                  lrq_quantity, 
                  stp_number,
                  fgt_number, 
                  cmp_id, 
                  def_id_type, 
                  lgh_number, 
                  mov_number,
                  lrq_default, 
                  cmd_code,
                  def_required,
                  -- PTS 18488 -- BL (start)
                  lrq_expire_date,
                  -- PTS 18488 -- BL (end)
                  lrg_cmp_billto, 
				  lrq_field,
				  lrq_units
        FROM      @lrq lr
      

-- Now remove any manual loadrequirements which are no longer valid
-- Get rid of manual lrqs based on commodity no longer on move
DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            ISNULL(lrq_default, 'N') = 'N' AND
            cmd_code <> 'UNKNOWN' AND
            NOT EXISTS (SELECT      *
                                FROM      @cmd cmd
                              WHERE      loadrequirement.cmd_code = cmd_code)

-- Get rid of manual lrqs based on company/stop type  no longer on order
DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            ISNULL(lrq_default, 'N') = 'N' AND
            cmp_id <> 'UNKNOWN' AND
            def_id_type <> 'BOTH' AND
            NOT EXISTS (SELECT      *
                                FROM      @cmpstop cmpstop
                              WHERE      loadrequirement.cmp_id = cmpstop.cmp_id AND
                                          loadrequirement.def_id_type = cmpstop.stp_type)

DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            ISNULL(lrq_default, 'N') = 'N' AND
            cmp_id <> 'UNKNOWN' AND
            def_id_type = 'BOTH' AND
            NOT EXISTS (SELECT      *
                                FROM      @cmpstop cmpstop
                              WHERE      loadrequirement.cmp_id = cmpstop.cmp_id)

-- Get rid of manual lrqs based on company/ stop type / commod no longer on order
DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            ISNULL(lrq_default, 'N') = 'N' AND
            cmd_code <> 'UNKNOWN' AND
            cmp_id <> 'UNKNOWN' AND
            def_id_type <> 'BOTH' AND
            NOT EXISTS (SELECT      *
                                FROM      @cmpcmdstop cmpcmdstop
                              WHERE      loadrequirement.cmp_id = cmpcmdstop.cmp_id AND
                                          loadrequirement.def_id_type = cmpcmdstop.stp_type AND
                                          loadrequirement.cmd_code = cmpcmdstop.cmd_code)

DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            ISNULL(lrq_default, 'N') = 'N' AND
            cmd_code <> 'UNKNOWN' AND
            cmp_id <> 'UNKNOWN' AND
            def_id_type = 'BOTH' AND
            NOT EXISTS (SELECT      *
                                FROM      @cmpcmdstop cmpcmdstop
                              WHERE      loadrequirement.cmp_id = cmpcmdstop.cmp_id AND
                                          loadrequirement.cmd_code = cmpcmdstop.cmd_code)

-- Remove requirements from movements where there is no longer an Order with 
--          a Bill To requirement.
DELETE 
  FROM      loadrequirement
WHERE      mov_number = @movnumber AND
            cmp_id <> 'UNKNOWN' AND
            def_id_type = 'BOTH' AND
            def_cmp_billto = 'Y'
            and NOT EXISTS (SELECT  1
                                FROM      Orderheader o
                              WHERE      loadrequirement.cmp_id = o.ord_billto)

RETURN
GO
DECLARE @xp float
SELECT @xp=1.01
EXEC sp_addextendedproperty N'Version', @xp, 'SCHEMA', N'dbo', 'PROCEDURE', N'reset_loadrequirements_sp', NULL, NULL
GO
