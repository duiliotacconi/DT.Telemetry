page 50133 "01. Lock Timeout"
{
    Caption = '01. Lock Timeout';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(INPUT)
            {
                field(NewShelfNo; NewShelfNo)
                {
                    Caption = 'NEW Item Shelf No.';
                    ApplicationArea = All;
                }
            }
            group(OUTPUT)
            {
                field(Result; Result)
                {
                    Caption = 'Result';
                    ApplicationArea = All;
                    MultiLine = true;
                }
                field(ElapsedTime; ElapsedTime)
                {
                    Caption = 'Duration';
                    ApplicationArea = All;
                }
            }
            group("Session")
            {
                field(CurrentSessionId; CurrentSessionId)
                {
                    Caption = 'BC Server Session Id';
                    Editable = false;
                    Enabled = false;
                    Style = Attention;
                    ApplicationArea = All;
                }
            }

        }
    }

    actions
    {
        area(Processing)
        {
            action(LooooongALUpdate)
            {
                Caption = 'Looong AL Update (60secs)';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = UpdateDescription;

                trigger OnAction()
                var
                    Item: Record "Item";
                    OldValue: Text;
                    NewValue: Text;
                begin
                    StartDateTime := CurrentDateTime;
                    if Item.FindSet() then
                        repeat
                            if Item."No." = '1928-S' then begin
                                OldValue := Item."Shelf No.";
                                Item."Shelf No." := NewShelfNo;
                                Item.Modify();
                            end;
                        until Item.Next() = 0;

                    Sleep(60000); //Wait 1 minute
                    
                    Result := 'UPDATE Transaction Ended. OLD: [' + OldValue + '] - NEW: [' + NewShelfNo + ']';
                    ElapsedTime := CurrentDateTime - StartDateTime;

                    CurrPage.Update();
                end;
            }

            action(ItemReadLoopInUpdlock)
            {
                Caption = 'READ loop with UPDLOCK';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = RelatedInformation;

                trigger OnAction()
                var
                    Item: Record "Item";
                begin
                    Result := '';
                    StartDateTime := CurrentDateTime;

                    Item.ReadIsolation := IsolationLevel::UpdLock;                    
                    if Item.FindSet() then
                    repeat
                        //just reading all Items with a UPDLOCK
                    until Item.Next() = 0;
                    ElapsedTime := CurrentDateTime - StartDateTime;

                    CurrPage.Update();
                end;

            }

            action(ResetShelfNo)
            {
                Caption = 'RESET Shelf No.';
                ApplicationArea = All;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Restore;

                trigger OnAction()
                var
                    Item: Record "Item";
                begin
                    if Item.Get('1928-S') then begin
                        Item."Shelf No." := 'OLDVALUE';
                        Item.Modify();
                    end;
                    Clear(Result);
                    Clear(ElapsedTime);

                    CurrPage.Update();
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        NewShelfNo := 'ABC123';
        CurrentSessionId := SessionId();
    end;

    var
        NewShelfNo: Code[10];
        Result: Text;
        StartDateTime: DateTime;
        ElapsedTime: Duration;
        TriStateLockingStatus: Text;
        CurrentSessionId : Integer;

}