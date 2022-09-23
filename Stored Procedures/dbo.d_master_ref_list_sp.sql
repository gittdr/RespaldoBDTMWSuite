SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_master_ref_list_sp] 
    @userid char(20), 
    @branch1 varchar(6), 
    @branch2 varchar(6), 
    @branch3 varchar(6), 
    @show_commodities char(1)
AS  


/************************************************************************************
 NAME:        d_master_ref_list_sp
 TYPE:        stored procedure
 DATABASE:  TMW
 PURPOSE:   Obtains all of the master orders that the user would like to see
            based on their ini settings.
    
            If a specific branch id is given, that means they want a specific
            branch, so override the INI settings,    
        
            This procedure has been modified from its original FSS incarnation to 
            accept all ini settings as arguments. At the time of this writing ini 
            settings were not being stored to the database, so all ini settings were
            determined through the app and then passed to the stored procedure through
            the data window data source retrieval.
        
        
 RETURNS:   The selected list.


REVISION LOG

DATE          WHO             REASON
----          ---             ------
19-Apr-02     Tannis Drysdale Created
23-Apr-02     Tannis Drysdale Error checking added.
24-Apr-02     Tannis Drysdale If/then formating.
05-Jun-02     Tannis Drysdale Display commodities (up to three) on last drop off (destination)
23-Jul-02     NNIU            Replaced the sub-query with a While loop for branch processing to improve speed.
23-Aug-02     DCOLLIER        Added code to retrieve the users ini setting which will determine if
                              the commodities are included in the retrieval. Also, see below where
                              o.ord_status <> 'CAN' was chnaged to o.ord_status = 'MST'
19-Sep-07     Ryan Hing       Modified to accept the profile string as an argument for TMWGap SR38781 to allow
                              the application to read the profile string instead of directly accessing the tables
                              through another stored proc.
01-Oct-07     Ryan Hing       Added sample execution line.

execute d_master_ref_list_sp '', '002C', '011C', '', 'Y'

*************************************************************************************/

declare @file_id           int,
        @section_id        int,
        @fs_id             int,
        @sequence          int,
        @ord_hdrnumber     int,
        @max_ord_hdrnumber int,
        @comm_count        int,
        @max_count         int,
        @curr_count        int,
        @fgt_number        int,
        @cmd_code          varchar(8),
        @cmd_desc          varchar(30),
        @usr_userid        varchar(20),
        @this_branch       varchar(6)

CREATE TABLE #branches(
    branch_id   varchar(255)   NULL
)

-- TJD 5-Jun-02 
CREATE TABLE #master_orders(
    master_refnumber    char(15)        NOT NULL,
    ord_hdrnumber       int             NOT NULL,
    ord_revtype1        varchar(6)      NOT NULL,
    ord_company         varchar(8)      NOT NULL,
    ord_originpoint     varchar(8)      NOT NULL,
    ord_destpoint       varchar(8)      NOT NULL,
    ord_cmp_name        varchar(30)     NOT NULL,
    orig_cmp_name       varchar(30)     NOT NULL,
    dest_cmp_name       varchar(30)     NOT NULL,
    cmd_code_1          varchar(8)      NULL,
    cmd_desc_1          varchar(60)     NULL,		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
    cmd_code_2          varchar(8)      NULL,
    cmd_desc_2          varchar(60)     NULL,		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
    cmd_code_3          varchar(8)      NULL,
    cmd_desc_3          varchar(60)     NULL 		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
)

-- TJD 5-Jun-02 
CREATE TABLE #commodities
(
    cmd_code            varchar(8)      NULL,
    fgt_description     varchar(60)     NULL,		/* // 02/11/2008 MDH PTS 41231: Changed to varchar (60) */
    fgt_sequence        smallint        NULL,
    stp_number          int             NULL,
    fgt_number          int             NULL
)

-- Check to see if any of the branches have been entered
-- No branches specified: Default to 'UNK'
if @branch1 is null and @branch2 is null and @branch3 is null
    begin
        insert into #branches (branch_id) values ('UNK')
  end

-- Branches have been specified insert them into the #branches table
else
    begin
        insert into #branches (branch_id) select @branch1
        insert into #branches (branch_id) select @branch2
        insert into #branches (branch_id) select @branch3
    end


-- Get all master orders for all of the branches 
-- Select into a table so we can update the first pickup and last dropoff later 

-- Begin iterating through the branch list picking up all of the Master Orders for each
select @this_branch = min(branch_id) from #branches

while @this_branch <> null
    begin
        INSERT INTO #master_orders
        ( master_refnumber,
          ord_hdrnumber,
          ord_revtype1,
          ord_company,
          ord_originpoint,
          ord_destpoint,
          ord_cmp_name,
          orig_cmp_name,
          dest_cmp_name
        )

    -- Also index should be placed on ord_hdrnumber on masterorders_ref 
        select m.master_refnumber,
           m.ord_hdrnumber,
           m.ord_revtype1,
           o.ord_company,
           o.ord_originpoint, 
           o.ord_destpoint,
           c1.cmp_name as 'ord_cmp_name',
           c2.cmp_name as 'orig_cmp_name',
           c3.cmp_name as 'dest_cmp_name'
        from masterorders_ref m,
         orderheader o,
         company c1,
         company c2,
         company c3
        where m.ord_hdrnumber = o.ord_hdrnumber
        and o.ord_company = c1.cmp_id
        and o.ord_originpoint = c2.cmp_id
        and o.ord_destpoint = c3.cmp_id
        and o.ord_status = 'MST'
        and m.ord_revtype1 = @this_branch

        select @this_branch = min(branch_id) from #branches where branch_id > @this_branch
    end -- While


-- Update the commodities 

if @show_commodities = 'Y'
begin

    select @ord_hdrnumber = min(ord_hdrnumber)
    from #master_orders

    select @max_ord_hdrnumber = max(ord_hdrnumber)
    from #master_orders

    while @ord_hdrnumber <= @max_ord_hdrnumber
    begin


        -- Commodities for all drop offs on order 
        INSERT INTO #commodities
        (
        cmd_code,
        fgt_description,
        fgt_sequence,
        stp_number,
        fgt_number
        )
        select f.cmd_code,
         f.fgt_description,
         f.fgt_sequence,
         f.stp_number,
         f.fgt_number
        from stops s, freightdetail f
        where s.stp_number = f.stp_number
        and s.ord_hdrnumber = @ord_hdrnumber
        and s.stp_type = 'DRP'

        select @max_count = count(*)
        from #commodities

        -- We only want three commodities 
        if @max_count > 3
            begin
                select @comm_count = 3
            end
        else
            begin
                select @comm_count = @max_count
            end

        select @curr_count = 1

        while @curr_count <= @comm_count
        begin
            select @fgt_number = min(fgt_number)
            from #commodities

            select @cmd_code = cmd_code,
              @cmd_desc = fgt_description
            from #commodities
            where fgt_number = @fgt_number

        if @curr_count = 1
         begin
           UPDATE #master_orders
             set cmd_code_1 = @cmd_code,
                 cmd_desc_1 = @cmd_desc
             where ord_hdrnumber = @ord_hdrnumber
          end
         else
          begin
            if @curr_count = 2
               begin
                 UPDATE #master_orders
                   set cmd_code_2 = @cmd_code,
                       cmd_desc_2 = @cmd_desc
                   where ord_hdrnumber = @ord_hdrnumber
               end
            else
               begin
                 UPDATE #master_orders
                   set cmd_code_3 = @cmd_code,
                       cmd_desc_3 = @cmd_desc
                   where ord_hdrnumber = @ord_hdrnumber
               end
         end

            --Remove row 
            delete
            from #commodities
            where fgt_number = @fgt_number

            -- increment count
            select @curr_count = @curr_count + 1

        end -- while commodity

        -- remove all data from #commodities because this order is done 
        delete
        from #commodities


        select @ord_hdrnumber = min(ord_hdrnumber)
        from #master_orders
        where ord_hdrnumber > @ord_hdrnumber

    end -- outer while 
end -- end if  


-- Final select from new temp table
select master_refnumber,
       ord_hdrnumber,
       ord_revtype1,
       ord_company,
       ord_originpoint,
       ord_destpoint,
       ord_cmp_name,
       orig_cmp_name,
       dest_cmp_name,
       cmd_code_1,
       cmd_desc_1,
       cmd_code_2,
       cmd_desc_2,
       cmd_code_3,
       cmd_desc_3
from #master_orders

drop table #branches
drop table #master_orders
drop table #commodities

GO
GRANT EXECUTE ON  [dbo].[d_master_ref_list_sp] TO [public]
GO
