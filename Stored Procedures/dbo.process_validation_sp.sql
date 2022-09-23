SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_validation_sp]
(@order_num     int,
@invoice_num    int,
@val_group      int,
@batch_num      int,
@parm1          varchar(255),
@ret_err_count  int OUT,
@ret_batch_num  int OUT
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be the main validation stored procedure.
It will be called from nvo_validation.process_validation. It will perform the necessary validation tests for an individual validation group. If validation rules are broken, it will log the errors, and call process_validation_actions_sp and let that SP decide what the consequences should be. Finally, it will report
back the number of violations, and the tts_errorlog batch number to the NVO.
TGRIFFIT 38797 12/20/2007 - treat empty strings as null values - in the Trip Folder when the
user clears data from the Ref# column and saves, an empty string persists. 

*/
    SET NOCOUNT ON
    
    DECLARE @total_errors int,
            @val_group_name varchar(255),
            @error_msg varchar(255),
            @curr_fetch int,
            @max_fetch  int,
            @fetch_rule varchar(255),
            @fail_rule varchar(255),
            @ord_num_string varchar(255),
            @inv_num_string varchar(255),
            @batch_num_string varchar(255),
            @value  varchar(255),
            @temp_value varchar(255),
            @max_value  varchar(255),
            @values_count int,
            @curr_id int,
            @max_id int,
            @cur_type varchar(255),
            @cur_pos int,
            @cur_length int,
            @cur_value varchar(255),
            @curr_character char(1),
            @cur_set_start int,
            @max_set_start int,
            @set_count int,
            @in_set int
               
    SELECT @total_errors = 0
    SELECT @ret_err_count = 0
    SELECT @ret_batch_num = 0
    
    BEGIN
    
        SELECT @val_group = ISNULL(@val_group, 0)
        
        IF @val_group = 0
        BEGIN
        
           IF @batch_num = 0
           BEGIN
              EXECUTE @batch_num = getsystemnumber 'BATCHQ', ''
           END
                        
            INSERT INTO tts_errorlog
                (err_batch,
                err_user_id,
                err_message,
                err_date,
                err_item_number)
            SELECT @batch_num,
                user,
                'VALIDATION GROUP ID MISSING',
                GETDATE(),
                @order_num
                
            SELECT @ret_err_count = 1
            SELECT @ret_batch_num = @batch_num
            
            RETURN
        END
        
        CREATE TABLE #set_value
        (set_value varchar(255) NULL, set_pos int NULL, set_len int NULL)

        CREATE TABLE #value
        (val_information varchar(255) NULL)
               
        CREATE TABLE #filter
        (value varchar(255) NULL)
        
        SELECT @val_group_name = valg_name,
               @error_msg = valg_description,
               @fail_rule = vals_name,
               @ord_num_string = CAST(@order_num AS VARCHAR),
               @inv_num_string = CAST(@invoice_num AS VARCHAR),
               @batch_num_string = CAST(@batch_num AS VARCHAR)
        FROM validation_group
            LEFT OUTER JOIN validation_section
            ON vals_id = valg_failure_section_id 
        WHERE valg_id = @val_group
        
        /* We need to loop through the different fetch sections so we validate one value at a time */
        SELECT @curr_fetch = MIN(val_fetch_section_id),
               @max_fetch = MAX(val_fetch_section_id)
        FROM validation
        WHERE val_valg_id = @val_group

        WHILE (@curr_fetch <= @max_fetch)
        BEGIN
            
            /* clear out the tables */
            DELETE FROM #value
            DELETE FROM #filter
        
            /* use the validation record's fetch section id to determine which rule needs to be validated*/
            SELECT @fetch_rule = vals_name
            FROM validation_section
            WHERE vals_id = @curr_fetch
        
            /* now get a list of values that need to be validated */
            
            SELECT @values_count = 0
            
            EXEC @values_count = process_validation_values_sp 
                @fetch_rule, @ord_num_string, @inv_num_string, @batch_num_string, ''

        IF @values_count > 0
            BEGIN            
                
                /* TGRIFFIT 38797 12/20/2007 ADDED THE OR CONDITION BELOW */              
                UPDATE #value
                SET val_information = 'NULLVALUE'
                WHERE val_information IS NULL
                OR LTRIM(RTRIM(val_information)) = '' 
                             
                
                /* filter duplicate rows */
                INSERT INTO #filter
                SELECT DISTINCT(val_information)
                FROM #value
    
                DELETE FROM #value
    
                INSERT INTO #value
                SELECT value FROM #filter
                
                 /* Loop thorough current values in the #value table */
                SELECT @value = MIN(val_information),
                       @max_value = MAX(val_information)
                FROM #value
                
                WHILE @value <= @max_value
                BEGIN
                
                    /* clear out our set table */
                    DELETE FROM #set_value
    
                   /* Loop through the individual rules for this group and fetch section */
                    SELECT @curr_id = min(val_id),
                           @max_id = max(val_id)
                    FROM validation
                    WHERE val_valg_id = @val_group
                    AND val_fetch_section_id = @curr_fetch
        
                    WHILE (@curr_id <= @max_id)
                    BEGIN
                
                        /* Actual validation logic */
                    
                        /* Get info from current validation */
                        
                        SELECT @cur_type = ''
                        SELECT @cur_pos = 0
                        SELECT @cur_length = 0
                        SELECT @cur_value = ''
                        
                        SELECT @cur_type = val_type,
                               @cur_pos = val_position,
                               @cur_length = val_length,
                               @cur_value = val_value
                        FROM validation
                        WHERE val_id = @curr_id
    
                       /* Depending on type, we will want different processing */
                       /* If you want to add new types, add them to the labelfile
                           and put their processing here */
    
                       /* Current supported types and their description
                              Abbr      Name                Desc
                              ALALNU    All Alphanumeric    Value must be alphanumeric
                              ALAPHA    All Alpha           Value must be alphabetic
                              ALNUM     All Numeric         Value must be numeric
                              GT        Greater Than        Value must be greater than value column
                              ISALNU    Is Alphanumeric     Substring (determined by pos/lenght columns)
                                                            must be alphanumeric
                              ISAPHA    Is Alpha            Substring (determined by pos/lenght columns)
                                                            must be alphabetic
                              ISNUM     Is Numeric          Substring (determined by pos/lenght columns)
                                                            must be numeric
                              LEN       Length              Lenght of value must be same as length column
                              LT        Less Than           Value must be less than value column
                              MASK      Mask                Substring (determined by pos/length columns)
                                                            must match value
                              NNULL     Not Null            Value must not be null
                              SET       Set                 Value must be the subset of all sets of the rule
                          */
    
                        /* ASCII Information
                            Character       ASCII Value
                             0-9             48-57
                             A-Z             65-90
                             a-z             97-122
    
                        */
    
                        /* All or portion is alphanumeric */
                        IF (@cur_type = 'ALALNU') OR (@cur_type = 'ISALNU')
                        BEGIN
                            /* Store value in temp holder so we can modify it*/
                            IF @cur_type = 'ALALNU'
                                BEGIN
                                    /* Want whole thing */
                                    SELECT @temp_value = @value
                                END
                            ELSE
                                BEGIN
                                    /* Only want a portion of it */
                                    SELECT @temp_value = SUBSTRING(@value, @cur_pos, @cur_length)
                                END
        
                             /* Loop through character by character validating */
                            WHILE (LEN(@temp_value) > 0) AND (@total_errors = 0)
                            BEGIN
                                /* get the first character */
                                SELECT @curr_character = SUBSTRING(@temp_value,1,1)
                            
                                /* Check ascii value to see if a number or a letter */
                                IF (ascii(@curr_character) < 48) OR (ascii(@curr_character) > 122) OR
                                   ((ascii(@curr_character) > 90) AND (ascii(@curr_character) < 97))  OR
                                   ((ascii(@curr_character) > 57) AND (ascii(@curr_character) < 65)) OR
                                   /* If value is Null then it fails */
                                   (@value = 'NULLVALUE')
                                BEGIN
                                    SELECT @total_errors = @total_errors + 1
                                END
                            
                                /* Parse off the first digit */
                                SELECT @temp_value = SUBSTRING(@temp_value, 2, LEN(@temp_value) - 1)
                            END    
                        END
    
                        /* All Alpha or portion alpha */
                        IF (@cur_type = 'ALAPHA') OR (@cur_type = 'ISAPHA')
                        BEGIN
                            /* Store value in temp holder so we can modify it*/
                            IF @cur_type = 'ALAPHA'
                                BEGIN
                                    /* Want whole thing */
                                    SELECT @temp_value = @value
                                END
                            ELSE
                                BEGIN
                                    /* Only want a portion of it */
                                    SELECT @temp_value = SUBSTRING(@value, @cur_pos, @cur_length)
                                END

                            /* Loop through character by character validating */
                            WHILE (LEN(@temp_value) > 0) AND (@total_errors = 0)
                            BEGIN
                                /* get the first character */
                                SELECT @curr_character = SUBSTRING(@temp_value,1,1)

                                /* Check ascii value to see if a number */
                                IF (ascii(@curr_character) < 65) OR (ascii(@curr_character) > 122) OR
                                   ((ascii(@curr_character) > 90) AND (ascii(@curr_character) < 97)) OR
                                   /* if null will fail */
                                   (@value = 'NULLVALUE')
                                    BEGIN
                                        SELECT @total_errors = @total_errors + 1
                                    END

                                /* Parse off the first digit */
                                SELECT @temp_value = SUBSTRING(@temp_value, 2, LEN(@temp_value) - 1)
                            END
                        END

                        /* All Numeric  or partially numeric*/
                        IF (@cur_type = 'ALNUM')  OR (@cur_type = 'ISNUM')
                        BEGIN
                              /* Store value in temp holder so we can modify it*/
                            IF @cur_type = 'ALNUM'
                            BEGIN
                                /* Want whole thing */
                                SELECT @temp_value = @value
                            END
                            ELSE
                            BEGIN
                                /* Only want a portion of it */
                                SELECT @temp_value = SUBSTRING(@value, @cur_pos, @cur_length)
                            END
    
                            /* Loop through character by character validating */
                            WHILE (LEN(@temp_value) > 0) AND (@total_errors = 0)
                            BEGIN
                                /* get the first character */
                                SELECT @curr_character = SUBSTRING(@temp_value,1,1)
    
                                /* Check ascii value to see if a number */
                                IF (ascii(@curr_character) < 48) OR
                                   (ascii(@curr_character) > 57)  OR
                                   /* If value is Null then it fails */
                                    (@value = 'NULLVALUE')
                                BEGIN
                                    SELECT @total_errors = @total_errors + 1
                                END
    
                                /* Parse off the first digit */
                                SELECT @temp_value = SUBSTRING(@temp_value, 2, LEN(@temp_value) - 1)
                            END
                        END
    
                        /* Greater Than */
                        IF @cur_type = 'GT'
                        BEGIN
                            IF @value = 'NULLVALUE' OR (ISNUMERIC(@value)<> 1)
                            BEGIN
                                SELECT @total_errors = @total_errors + 1
                            END
                            ELSE
                            BEGIN
                                IF convert(int, @value) <= convert( int, @cur_value)
                                BEGIN
                                    SELECT @total_errors = @total_errors + 1
                                END
                            END
                        END
    
                        /* Less Than */
                        IF @cur_type = 'LT'
                        BEGIN
                            IF @value = 'NULLVALUE' OR (ISNUMERIC(@value)<> 1)
                            BEGIN
                                SELECT @total_errors = @total_errors + 1
                            END
                            ELSE
                            BEGIN
                                IF convert(int, @value) >= convert(int, @cur_value)
                                BEGIN
                                    SELECT @total_errors = @total_errors + 1
                                END
                            END
                        END
    
                        /* Not Equal to */
                        IF @cur_type = 'NTEQ'
                        BEGIN
                            IF @value = 'NULLVALUE' OR (ISNUMERIC(@value)<> 1)
                            BEGIN
                                SELECT @total_errors = @total_errors + 1
                            END
                            ELSE
                            BEGIN                                
                                IF convert(int, @value) = convert(int, @cur_value) 
                                BEGIN
                                    SELECT @total_errors = @total_errors + 1
                                END
                            END
                        END
    
                        /* Length */
                        IF @cur_type = 'LEN'
                        BEGIN
                            IF LEN(@value) != @cur_length OR (@value = 'NULLVALUE')
                            BEGIN
                                SELECT @total_errors = @total_errors + 1
                            END
                        END
    
                        /* Mask */
                        IF @cur_type = 'MASK'
                        BEGIN
                            IF SUBSTRING(@value, @cur_pos, @cur_length) != @cur_value OR
                                (@value = 'NULLVALUE')
                            BEGIN
                                SELECT @total_errors = @total_errors + 1 
                            END
                        END
    
    
                        /*Not Null */
                        IF @cur_type = 'NNULL'
                        BEGIN
                            IF (@value = 'NULLVALUE')
                            BEGIN
                                SELECT @total_errors = @total_errors + 1
                            END
                        END
        
                        /* Set */
                        IF @cur_type = 'SET'
                        BEGIN
                            /* Insert current value into our subset table */
                            IF ISNULL(@cur_pos,0) = 0
                            BEGIN
                                SELECT @cur_pos = 1
                            END
                            
                            IF ISNULL(@cur_length, 0) = 0
                            BEGIN
                                SELECT @cur_length = LEN(@value)
                            END
                            
                            INSERT INTO #set_value
                            (set_value, set_pos, set_len)
                            SELECT @cur_value, @cur_pos, @cur_length
                        END
                                
                        /* end of actual validation logic */
                               
                        /* next rule for this fetch section */
                        SELECT @curr_id = MIN(val_id)
                        FROM validation
                        WHERE val_valg_id = @val_group
                        AND val_id > @curr_id
                        AND val_fetch_section_id = @curr_fetch
                         
                        IF ISNULL(@curr_id,0)= 0 BREAK                                 
                           
                    END /* VALIDATION TABLE LOOP */

                    /* if we have anything in the set table, check it, only if we have no errors so far*/
                    SELECT @set_count = count(1)
                    FROM #set_value

                    IF @set_count > 0
                    BEGIN
                        /* We may have more that one set validation per item, loop throught them */
                        SELECT @cur_set_start = min(set_pos),
                               @max_set_start = max(set_pos)
                        FROM #set_value
                        
                        WHILE @cur_set_start <= @max_set_start
                        BEGIN
                            /* Check to see if our value is in the subset */
                            SELECT @in_set = count(1)
                            FROM #set_value
                            WHERE SUBSTRING(rtrim(ltrim(@value)), set_pos, set_len) = rtrim(ltrim(set_value))
                            AND set_pos = @cur_set_start
 
                            IF (@in_set = 0) OR (ISNULL(@in_set, 0) = 0) 
                            BEGIN       
                                SELECT @total_errors = @total_errors + 1
                            END
                            
                            SELECT @cur_set_start = MIN(set_pos)
                            FROM #set_value
                            WHERE set_pos > @cur_set_start
                        END
                    END

                    
                    SELECT @value = MIN(val_information)
                    FROM #value
                    WHERE val_information > @value
                    
                    IF ISNULL(@value,'')= '' BREAK
                    
                END /* #VALUE TABLE LOOP */
                
            END
            
            SELECT @curr_fetch = MIN(val_fetch_section_id)
            FROM validation
            WHERE val_valg_id = @val_group
            AND val_fetch_section_id > @curr_fetch
            
            IF ISNULL(@curr_fetch,0)= 0 BREAK
        
        END /* FETCH SECTION LOOP */
        
        IF @total_errors > 0
        BEGIN
        
           IF @batch_num = 0
           BEGIN
              EXECUTE @batch_num = getsystemnumber 'BATCHQ', ''
              SELECT @batch_num_string = CAST(@batch_num AS VARCHAR)
           END
        
            IF @invoice_num > 0
                BEGIN
                    SELECT @error_msg = UPPER(@error_msg + ' Invoice: ' + CAST(ivh_invoicenumber AS VARCHAR))
                    FROM invoiceheader
                    WHERE ivh_hdrnumber = @invoice_num
                END
            ELSE
                BEGIN
                    SELECT @error_msg = UPPER(@error_msg + ' Order: ' + CAST(@order_num AS VARCHAR))
                END
            
            INSERT INTO tts_errorlog
                (err_batch,
                 err_user_id,
                 err_message,
                 err_date,
                 err_item_number)
            SELECT @batch_num,
                 user,
                 @error_msg,
                 GETDATE(),
                 @order_num
            
            /* Perform Failure action (failure section is stored at the group level) */
            EXEC process_validation_actions_sp 
                @fail_rule, @ord_num_string, @inv_num_string, @batch_num_string, ''
        
        END
        
        DROP TABLE #set_value
        DROP TABLE #value
        DROP TABLE #filter
        
        SELECT @ret_err_count = @total_errors
        SELECT @ret_batch_num = @batch_num
           
    END
GO
GRANT EXECUTE ON  [dbo].[process_validation_sp] TO [public]
GO
