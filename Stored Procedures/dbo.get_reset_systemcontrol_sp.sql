SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_reset_systemcontrol_sp] (@ps_entity varchar(25), @pdtm_now datetime, @pi_rule int)
AS

/**
 * 
 * NAME:
 * dbo.get_reset_systemcontrol_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure gets a resetable systemcontrol number
 *
 * RETURNS:
 * [N/A]
 *
 * RESULT SETS: 
 *   Returns -1 if it is unable to generate a new system control number
 *   Otherwise returns the new system control number
 *
 * PARAMETERS:
 * 001 - @ps_entity, varchar(25), input, not null;
 *       This parameter indicates type of system control number to get
 * 002 - @pdtm_now, datetime, input, not null;
 *       This parameter is the current system time
 * 003 - @pi_rule, int, input, not null;
 *       This parameter indicates the rule base to generate the number
 *       Currently support values include:
 *       1:  This is the inital rule defined (more to come as needed)  
 *           It indicates that the system control number needs to reset each morning at midnight
 *
 * REFERENCES: 
 * N/A
 * 
 * REVISION HISTORY:
 * 08/16/2006 ? PTS34031 - Jason Bauwin ? Original Release
 *
 **/



declare @v_tablename varchar(100), 
        @v_sql nvarchar(500), 
        @vi_ctrl_number int, 
        @v_today datetime, 
        @v_curr_ctrl_num int,
        @v_error int

create table #temp
		( control_number int NULL
                )
select @v_tablename = scrr_table
  from sys_control_reset_rules
 where scrr_entity = @ps_entity

--build logic for each rule type here
IF @pi_rule = 1
--Rule 1 resets the systemcontrol number to 1 each day
  begin
	select @v_today = convert(datetime,(convert(varchar(11), @pdtm_now, 101)))
	select @v_sql = 'insert into #temp (control_number) select max(cefn_ctrlnumber) from ' + @v_tablename + ' where cefn_date = ''' + convert(varchar(30),@v_today, 121) + ''''
	--make this all one transaction so there is no overlap
        begin transaction
	EXEC sp_executesql @v_sql
        SELECT @v_error = @@error
        if @v_error > 0
	begin
	  rollback
          select -1
	  RETURN
        end
	select @v_curr_ctrl_num = control_number
	  from #temp
	if @v_curr_ctrl_num is null
	begin
		select @v_sql = 'insert into ' + @v_tablename + '(cefn_date) values ' + '(''' + convert(varchar(30),@v_today, 121) + ''')'
                EXEC sp_executesql @v_sql
	        SELECT @v_error = @@error
	        if @v_error > 0
		begin
		  rollback
	          select -1
                  RETURN
	        end
		select 1
	end
	else
        begin
		select @v_sql = 'update ' + @v_tablename + ' set cefn_ctrlnumber = ' + convert(varchar(4),(@v_curr_ctrl_num + 1)) + ' where cefn_date = ''' + convert(varchar(30),@v_today, 121) + ''''
		EXEC sp_executesql @v_sql
	        SELECT @v_error = @@error
	        if @v_error > 0
		begin
		  rollback
	          select -1
		  RETURN
	        end
		select @v_curr_ctrl_num + 1
        end
  end
commit transaction
GO
GRANT EXECUTE ON  [dbo].[get_reset_systemcontrol_sp] TO [public]
GO
