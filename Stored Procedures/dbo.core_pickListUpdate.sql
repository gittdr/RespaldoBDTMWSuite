SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_pickListUpdate]
    @labelfile_labeldefinition varchar (20),
    @labelfile_name varchar (20),
    @labelfile_abbr varchar (6),
    @labelfile_code int,
    @labelfile_locked char (1),
    @labelfile_userlabelname varchar (20),
    @labelfile_edicode varchar (6),
    @labelfile_systemcode char (1),
--  @labelfile_hours int,
--  @labelfile_opercost float,
--  @labelfile_fueltype varchar(6),
    @labelfile_retired char (1),
    @labelfile_inventory_item varchar (1),
    @labelfile_acct_db varchar (10),
    @labelfile_ic_clear_glnum varchar (66),
    @labelfile_acct_server varchar (20),
    @labelfile_pyt_itemcode varchar (6),
    @labelfile_teamleader_email varchar (50),
    @labelfile_auto_complete varchar (1),
    @labelfile_label_extrastring1 varchar (60),
    @labelfile_label_extrastring2 varchar (60),
    @labelfile_exclude_from_creditcheck varchar (1),
    @labelfile_create_move varchar (1)
AS
UPDATE [labelfile]
SET
    name = @labelfile_name,
    code = @labelfile_code,
    locked = @labelfile_locked,
    userlabelname = @labelfile_userlabelname,
    edicode = @labelfile_edicode,
    systemcode = @labelfile_systemcode,
--	hours = @labelfile_hours,
--  opercost = @labelfile_opercost,
--  fueltype = @labelfile_fueltype,
    retired = @labelfile_retired,
    inventory_item = @labelfile_inventory_item,
    acct_db = @labelfile_acct_db,
    ic_clear_glnum = @labelfile_ic_clear_glnum,
    acct_server = @labelfile_acct_server,
    pyt_itemcode = @labelfile_pyt_itemcode,
    teamleader_email = @labelfile_teamleader_email,
    auto_complete = @labelfile_auto_complete,
    label_extrastring1 = @labelfile_label_extrastring1,
    label_extrastring2 = @labelfile_label_extrastring2,
    exclude_from_creditcheck = @labelfile_exclude_from_creditcheck,
    create_move = @labelfile_create_move
WHERE
    labeldefinition = @labelfile_labeldefinition 
    AND abbr = @labelfile_abbr
GO
GRANT EXECUTE ON  [dbo].[core_pickListUpdate] TO [public]
GO
