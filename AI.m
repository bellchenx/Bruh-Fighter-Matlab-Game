function AI(user, ai)
    if ai.currentAction == 0
        dis = ai.x - user.x;
        r = randi([1 15]);
        if r == 1
            ai.startAction(3);
        else
            if abs(dis) < ai.range && abs(dis) > (ai.range/2)
                r = randi([1 100]);
                if r < 5
                    ai.startAction(3);
                elseif r < 90
                    ai.startAction(4);
                else
                    r = randi([1 2]);
                    if r == 1
                        ai.startAction(1);
                    else
                        ai.startAction(2);
                    end
                end
            else
                if dis > 0
                    r = randi([1 6]);
                    if r == 1
                        ai.startAction(1);
                    else
                        ai.startAction(2);
                    end
                else
                    r = randi([1 6]);
                    if r == 1
                        ai.startAction(2);
                    else
                        ai.startAction(1);
                    end
                end
            end
        end
    end
end