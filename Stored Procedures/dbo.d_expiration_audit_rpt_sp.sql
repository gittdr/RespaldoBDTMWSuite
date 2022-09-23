SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROC [dbo].[d_expiration_audit_rpt_sp] (@idtype VARCHAR(6), @idnumber VARCHAR(25))
as

set nocount on

--PTS 26385 Add additional strings for delete audit associated move info
--pts 56963 MTC 6.16.2011. Changed @idnumber to varchar(25), made Audit_Cursor a FF Cursor
--added indexes to support selects (for performance reasons).

DECLARE @vupdatenote varchar(255), @delimiter varchar(2),
	@string1 varchar(255),@string2 varchar(255),@string3 varchar(255),
	@string4 varchar(255),@string5 varchar(255),@string6 varchar(255),
	@string7 varchar(255),@string8 varchar(255),@string9 varchar(255),
	@string10 varchar(255),@string11 varchar(255), @string12 varchar(255),
        @string13 varchar(255), @string14 varchar(255), @string15 varchar(255),
	@string16 varchar(255), @string17 varchar(255),
	@vupdatedby varchar(20), @vlabeldefinition varchar(6),
	@vupdateddt datetime, @vkeyvalue varchar(255),
        @asset_type varchar(3),@asset_id varchar(8), @exp_action varchar(12), @exp_type varchar(20)
        
--PTS 46566 JJF 20121008 - make compatible with existing calls.  Client can be updated to pass in type/id without delimiters and this will be bypassed.
IF RIGHT(@idtype, 3) = '::%' BEGIN
	SELECT @idtype = LEFT(@idtype, 3)
END
IF LEFT(@idnumber, 3) = '%::' BEGIN
	SELECT	@idnumber = SUBSTRING(@idnumber, 4, CHARINDEX('::%', @idnumber) - 4)
END 
--END PTS 46566 JJF 20121008

DECLARE Audit_Cursor CURSOR FAST_FORWARD FOR
select updated_by, 
case
when activity = 'ExpirationComplete' then 'Completed'
when activity = 'ExpirationInsert' then 'Inserted'
when activity = 'ExpirationUpdate' then 'Updated'
when activity = 'ExpirationDelete' then 'Deleted'
else activity
end exp_action, 
updated_dt, key_value, update_note 
from expedite_audit 
--PTS 46566 JJF 20121008
--where expedite_audit.activity like 'Expiration%'
--and expedite_audit.ord_hdrnumber = 0
--and expedite_audit.update_note like @idtype
--and expedite_audit.update_note like @idnumber
where expedite_audit.exp_idtype = @idtype
	and expedite_audit.exp_id = @idnumber
--END PTS 46566 JJF 20121008
order by updated_dt DESC

select @delimiter = '::'

DECLARE @temp TABLE 
	(updated_by varchar (20)  ,
	exp_type varchar (20)  ,
	exp_action varchar(12),
	updated_dt datetime ,
	key_value varchar (240)  ,
        string1 varchar(240),
	asset_type varchar(3),
	asset_id varchar(25))

OPEN Audit_Cursor

FETCH NEXT FROM Audit_Cursor into @vupdatedby, @exp_action, @vupdateddt, @vkeyvalue, @vupdatenote
WHILE @@FETCH_STATUS = 0
BEGIN
    exec parse_string @vupdatenote OUT, @string1 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string2 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string3 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string4 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string5 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string6 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string7 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string8 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string9 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string10 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string11 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string12 OUT, @delimiter
    exec parse_string @vupdatenote OUT, @string13 OUT, @delimiter
	--PTS 26385 Add associated move auditing for deleted expirations
	exec parse_string @vupdatenote OUT, @string14 OUT, @delimiter
	exec parse_string @vupdatenote OUT, @string15 OUT, @delimiter
	exec parse_string @vupdatenote OUT, @string16 OUT, @delimiter
	exec parse_string @vupdatenote OUT, @string17 OUT, @delimiter
    select @asset_type = @string1
    select @asset_id = @string2
    select @exp_type = @string3
    select @vlabeldefinition = upper(@string1 + 'EXP')
    SELECT @exp_type = name FROM LABELFILE WHERE upper(LABELDEFINITION) = @vlabeldefinition
	AND ABBR = @exp_type
    if @exp_action = 'Updated'
    	BEGIN
 		select @string1 = @string4 + ' modified: ' +  @string5
   	END
    if @exp_action = 'Completed'
	BEGIN
		select @string1 = '[Exp date: ' +  @string5 + ']    [End date: ' + @string7 + ']   [Location: ' +  @string13 + ']   [Desc: ' +  @string9 + ']'
    	END
    if @exp_action = 'Inserted'
  	BEGIN
		select @string1 = '[Exp date: ' +  @string5 + ']    [End date: ' + @string7 + ']   [Location: ' +  @string13 + ']   [Desc: ' +  @string9 + ']'
	END
    if @exp_action = 'Deleted'
    	BEGIN
		select @string1 = '[Exp date: ' +  @string5 + ']    [End date: ' + @string7 + ']   [Location: ' +  @string13 + ']   [Desc: ' +  @string9 + ']   [Move Deleted: ' + @string15 + ']   [Associated Move:' + @string17 + ']'
    	END
    insert into @temp
	select @vupdatedby, @exp_type, @exp_action, @vupdateddt, @vkeyvalue,
               @string1, @asset_type,@asset_id
    FETCH NEXT FROM Audit_Cursor into @vupdatedby, @exp_action, @vupdateddt, @vkeyvalue, @vupdatenote

   
END

CLOSE Audit_Cursor
DEALLOCATE Audit_Cursor

select * From @temp

GO
GRANT EXECUTE ON  [dbo].[d_expiration_audit_rpt_sp] TO [public]
GO
