# One Piece Terminal Fortune - PowerShell
# 200+ quotes from across the entire series

$quotes = @(
    # --- Monkey D. Luffy ---
    @{ quote = "I will become the King of the Pirates!"; character = "Monkey D. Luffy" }
    @{ quote = "I don't want to conquer anything. I just think the guy with the most freedom in this whole ocean... that's the Pirate King!"; character = "Monkey D. Luffy" }
    @{ quote = "If you don't take risks, you can't create a future!"; character = "Monkey D. Luffy" }
    @{ quote = "I've set myself to become the King of the Pirates... and if I die trying... then at least I tried!"; character = "Monkey D. Luffy" }
    @{ quote = "Dying is not repaying a debt! Only weak men would die after making their friends cry!"; character = "Monkey D. Luffy" }
    @{ quote = "I don't want to be a hero. I don't want to be a savior. I just want to be a pirate!"; character = "Monkey D. Luffy" }
    @{ quote = "If I give up now, I'm going to regret it!"; character = "Monkey D. Luffy" }
    @{ quote = "You want to keep everyone from dying? That's naive. It's war."; character = "Monkey D. Luffy" }
    @{ quote = "Forgetting is like a wound. The wound may heal, but it has already left a scar."; character = "Monkey D. Luffy" }
    @{ quote = "It's not about whether it's possible or not. I'm gonna do it because I want to!"; character = "Monkey D. Luffy" }
    @{ quote = "I hate the idea of losing even more than I'm afraid of dying."; character = "Monkey D. Luffy" }
    @{ quote = "An adventure where we might get killed just sounds like fun!"; character = "Monkey D. Luffy" }
    @{ quote = "There is someone that I must meet again. And until that day... not even death itself can take my life away!"; character = "Monkey D. Luffy" }
    @{ quote = "Being alone is more painful than getting hurt."; character = "Monkey D. Luffy" }
    @{ quote = "If you hurt somebody or if somebody hurts you, the same red blood will be shed."; character = "Monkey D. Luffy" }
    @{ quote = "Even if my soul is in pieces, I'll make it back."; character = "Monkey D. Luffy" }
    @{ quote = "Only I can call my dream stupid!"; character = "Monkey D. Luffy" }
    @{ quote = "We're almost there. I can feel it... the One Piece."; character = "Monkey D. Luffy" }
    @{ quote = "My crew is more important than any treasure in the world."; character = "Monkey D. Luffy" }
    @{ quote = "Even if you're scared... you still have to smile. Because that's what protects the people you love."; character = "Monkey D. Luffy" }
    @{ quote = "I've been grinding my teeth since I was a kid wondering why I was born into this world. But I found the answer... it's you guys."; character = "Monkey D. Luffy" }

    # --- Roronoa Zoro ---
    @{ quote = "Nothing happened."; character = "Roronoa Zoro" }
    @{ quote = "When I decided to follow my dream, I had already discarded my life."; character = "Roronoa Zoro" }
    @{ quote = "A scar on the back is a swordsman's shame."; character = "Roronoa Zoro" }
    @{ quote = "There is nothing in this world that can stop me from becoming the world's greatest swordsman!"; character = "Roronoa Zoro" }
    @{ quote = "I'll never lose again. The next time I'm in a situation where I might lose... I'll just die before that happens."; character = "Roronoa Zoro" }
    @{ quote = "Get it wrong and try again. And again. And again. Until you get it right."; character = "Roronoa Zoro" }
    @{ quote = "If I can't even protect my captain's dream, then whatever ambitions I have are nothing but pipe dreams."; character = "Roronoa Zoro" }
    @{ quote = "People's dreams... don't ever end!"; character = "Roronoa Zoro" }
    @{ quote = "Only those who have suffered long can see the light within the shadows."; character = "Roronoa Zoro" }
    @{ quote = "I made a promise to the person I respected most. I can't break it, even in death."; character = "Roronoa Zoro" }
    @{ quote = "Life is like a ship at sea. You can't stop the waves, but you can learn to sail."; character = "Roronoa Zoro" }
    @{ quote = "Scars on the back are a swordsman's disgrace."; character = "Roronoa Zoro" }
    @{ quote = "No matter what happens, I'll keep on moving. Until this life runs out of me, I'll keep on walking."; character = "Roronoa Zoro" }
    @{ quote = "I'm going to be the world's greatest swordsman! My name may be infamous... but it's not a name I'm ashamed of!"; character = "Roronoa Zoro" }
    @{ quote = "Over a thousand!"; character = "Roronoa Zoro" }
    @{ quote = "I don't care who you are! I will surpass you!"; character = "Roronoa Zoro" }
    @{ quote = "Courage means being the only one who knows how terrified you are."; character = "Roronoa Zoro" }

    # --- Sanji ---
    @{ quote = "Bringing a woman to tears... that's unforgivable!"; character = "Sanji" }
    @{ quote = "I can't use weapons. My hands are only for cooking."; character = "Sanji" }
    @{ quote = "Men who can't wipe away the tears from a woman's eyes aren't real men."; character = "Sanji" }
    @{ quote = "A chef's hands are his greatest treasure."; character = "Sanji" }
    @{ quote = "Even if I have to crawl, I'll get back up and keep fighting."; character = "Sanji" }
    @{ quote = "I never thought a woman's tears would be my greatest weapon."; character = "Sanji" }
    @{ quote = "I swore I would never use my hands in a fight. But for food, to honor the old man, I'll use them for that."; character = "Sanji" }

    # --- Nami ---
    @{ quote = "I'll draw a map of the whole world someday!"; character = "Nami" }
    @{ quote = "Money is the most important thing in this world!"; character = "Nami" }
    @{ quote = "If you ask me to betray my friends again, I'll kill you myself."; character = "Nami" }
    @{ quote = "We have to run, Luffy! Even you can't beat the whole world!"; character = "Nami" }
    @{ quote = "I wanted to live! I wanted to live and I tried my best!"; character = "Nami" }
    @{ quote = "I've drawn the chart of the entire ocean in my mind."; character = "Nami" }
    @{ quote = "There's nothing scarier to me than going into the unknown... so let's go!"; character = "Nami" }
    @{ quote = "Maps are the dreams of the sea."; character = "Nami" }

    # --- Usopp ---
    @{ quote = "I may be a liar and a coward... but I'm still a member of this crew!"; character = "Usopp" }
    @{ quote = "I can't help it. Even though I know there's no chance of winning, I still want to try!"; character = "Usopp" }
    @{ quote = "I will become a brave warrior of the sea!"; character = "Usopp" }
    @{ quote = "I don't want to die... I don't want to die. I really don't want to die!"; character = "Usopp" }
    @{ quote = "Even if you're scared, sometimes you just have to push through and keep moving."; character = "Usopp" }
    @{ quote = "I'm the captain of the 8,000-man Usopp Pirates!"; character = "Usopp" }

    # --- Brook ---
    @{ quote = "Yohohoho! Death holds no fear for me, for I am already dead!"; character = "Brook" }
    @{ quote = "Even if our bodies are separated, the sound of my violin will reach you. That is my promise."; character = "Brook" }
    @{ quote = "A person dies twice: once when they take their last breath, and again when someone speaks their name for the last time."; character = "Brook" }
    @{ quote = "Memories... even if I can't see your face, I always remember your smile."; character = "Brook" }
    @{ quote = "Friendship... even if I can't feel it in these bones of mine, it lives in my soul!"; character = "Brook" }
    @{ quote = "No matter how dark the night, morning always comes."; character = "Brook" }
    @{ quote = "I am completely fine. I'm a skeleton."; character = "Brook" }
    @{ quote = "May I see your panties?"; character = "Brook" }
    @{ quote = "I love humans! Ahahaha!"; character = "Brook" }

    # --- Tony Tony Chopper ---
    @{ quote = "I became a doctor to cure all diseases! Someday, I'll cure everything."; character = "Tony Tony Chopper" }
    @{ quote = "I'm not a pet! I'm a doctor!"; character = "Tony Tony Chopper" }
    @{ quote = "Don't call me a raccoon dog!"; character = "Tony Tony Chopper" }
    @{ quote = "A doctor who can't save one person can't save anyone!"; character = "Tony Tony Chopper" }
    @{ quote = "I'll sail with you to the ends of the world!"; character = "Tony Tony Chopper" }
    @{ quote = "Even in the face of death, I will stand up. That is what a pirate doctor does."; character = "Tony Tony Chopper" }

    # --- Nico Robin ---
    @{ quote = "I want to live! Take me with you!"; character = "Nico Robin" }
    @{ quote = "I want to exist in this world... I want to live!"; character = "Nico Robin" }
    @{ quote = "The truth of history should never be destroyed. It will be read someday."; character = "Nico Robin" }
    @{ quote = "You can't see the whole picture until you look at it from the outside."; character = "Nico Robin" }
    @{ quote = "Fools who don't respect the past are doomed to repeat it."; character = "Nico Robin" }
    @{ quote = "Ohara was destroyed, but its spirit was not."; character = "Nico Robin" }
    @{ quote = "The world may not want me to exist... but I do. And I'll keep existing."; character = "Nico Robin" }
    @{ quote = "This is not just a journey. It's a statement that we exist."; character = "Nico Robin" }
    @{ quote = "Loneliness is no longer my concern. But I do understand loneliness."; character = "Nico Robin" }
    @{ quote = "Compared to the righteous greed of the rulers, the pirates are far more honorable!"; character = "Nico Robin" }
    @{ quote = "Poneglyphs are the dreams of those who couldn't speak. I will read their words for them."; character = "Nico Robin" }

    # --- Franky ---
    @{ quote = "SUPER!"; character = "Franky" }
    @{ quote = "I'll build a ship that no sea can sink!"; character = "Franky" }
    @{ quote = "A ship that I built with my own hands... I'll never let it sink!"; character = "Franky" }
    @{ quote = "The Thousand Sunny is our dream, built piece by piece... and not even you can touch it!"; character = "Franky" }
    @{ quote = "Weakness is not a sin. Giving up is."; character = "Franky" }

    # --- Gol D. Roger ---
    @{ quote = "Wealth, fame, power. The man who had everything in this world... that was the Pirate King, Gol D. Roger."; character = "Gol D. Roger" }
    @{ quote = "My wealth and treasures? If you want it, I'll let you have it. Look for it! I left all of it at that place!"; character = "Gol D. Roger" }
    @{ quote = "I don't regret a single thing."; character = "Gol D. Roger" }
    @{ quote = "The world is overflowing with things that want to be found."; character = "Gol D. Roger" }
    @{ quote = "Inherited will, the destiny of the age, and the dreams of its people. As long as people continue to pursue freedom, these things will never cease!"; character = "Gol D. Roger" }
    @{ quote = "I'm not going to die in a place like this!"; character = "Gol D. Roger" }
    @{ quote = "Nothing in the world can stop the tide of a man's will."; character = "Gol D. Roger" }
    @{ quote = "The One Piece is real!"; character = "Gol D. Roger" }

    # --- Whitebeard ---
    @{ quote = "My children... will never be slaves."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "A man who dies with no regrets... that's someone who really lived."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "I don't want money or fame. I want to be surrounded by my family."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "You're too young to talk about death like that."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "I will never yield."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "Even if all the world's powers are against us, we will fight."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "Smiles are always a treasure, even in times of adversity."; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "Marineford... I won't allow my sons' lives to end here!"; character = "Whitebeard (Edward Newgate)" }
    @{ quote = "Sake tastes best when you drink it with friends."; character = "Whitebeard (Edward Newgate)" }

    # --- Red-Haired Shanks ---
    @{ quote = "A man who can't fight for the people he loves... isn't even worth calling a pirate."; character = "Red-Haired Shanks" }
    @{ quote = "I used this arm to bet on the new age."; character = "Red-Haired Shanks" }
    @{ quote = "I don't care about my arm. He saved my life."; character = "Red-Haired Shanks" }
    @{ quote = "Go ahead and eat it. It will change your life."; character = "Red-Haired Shanks" }
    @{ quote = "When the time is right, let's meet on the high seas."; character = "Red-Haired Shanks" }
    @{ quote = "He inherited my hat... and he'll inherit my era."; character = "Red-Haired Shanks" }
    @{ quote = "A real man is someone who forgives another man for his transgressions."; character = "Red-Haired Shanks" }
    @{ quote = "Whatever happens to you on the sea, it depends on what you've got!"; character = "Red-Haired Shanks" }

    # --- Portgas D. Ace ---
    @{ quote = "I'm not a hero. Heroes have to achieve something. I just wanted to save the people I love."; character = "Portgas D. Ace" }
    @{ quote = "You are my little brother. No matter where you go or what you do, that will never change."; character = "Portgas D. Ace" }
    @{ quote = "I'm glad I was born. Thank you all."; character = "Portgas D. Ace" }
    @{ quote = "I lived the way I wanted to live, met the people I wanted to meet, and felt what I wanted to feel. That's enough."; character = "Portgas D. Ace" }
    @{ quote = "We have to live a life of no regrets."; character = "Portgas D. Ace" }
    @{ quote = "If you want to make your dream come true, you had better not sleep."; character = "Portgas D. Ace" }
    @{ quote = "I won't lose to anyone! I am Ace!"; character = "Portgas D. Ace" }
    @{ quote = "Whitebeard is the greatest pirate in the world! He is my father!"; character = "Portgas D. Ace" }

    # --- Sabo ---
    @{ quote = "I want to be free! That's the only reason I need to set sail!"; character = "Sabo" }
    @{ quote = "The revolutionary army fights for everyone who suffers."; character = "Sabo" }
    @{ quote = "I've forgotten many things... but I haven't forgotten that you saved me."; character = "Sabo" }
    @{ quote = "To achieve freedom, you must first free yourself from fear."; character = "Sabo" }
    @{ quote = "We're brothers, no matter what."; character = "Sabo" }
    @{ quote = "I fight for those who cannot fight for themselves."; character = "Sabo" }
    @{ quote = "I inherited his will. That is why I fight."; character = "Sabo" }

    # --- Trafalgar D. Water Law ---
    @{ quote = "I am neither the bad guy nor the good guy. I simply follow my own justice."; character = "Trafalgar D. Water Law" }
    @{ quote = "It was all a calculated gamble. I don't mind losing a few pieces if it means winning the whole game."; character = "Trafalgar D. Water Law" }
    @{ quote = "My goal has always been to destroy the whole rotten system called the World Government."; character = "Trafalgar D. Water Law" }
    @{ quote = "I never said I was your ally. I said we had a common enemy."; character = "Trafalgar D. Water Law" }
    @{ quote = "Don't die before I finish paying back my debt."; character = "Trafalgar D. Water Law" }
    @{ quote = "The weak don't get to decide anything, not even how they die."; character = "Trafalgar D. Water Law" }
    @{ quote = "There is no going back in life. We can only move forward."; character = "Trafalgar D. Water Law" }
    @{ quote = "It's not that I want to live. I just have something I need to do."; character = "Trafalgar D. Water Law" }
    @{ quote = "The ones who are weak, those who weren't able to change their fate... they are the ones who truly move history."; character = "Trafalgar D. Water Law" }

    # --- Donquixote Doflamingo ---
    @{ quote = "Justice will prevail, you say? Of course it will! Whoever wins this war becomes justice!"; character = "Donquixote Doflamingo" }
    @{ quote = "Pirates are evil? The Marines are righteous? These are just labels."; character = "Donquixote Doflamingo" }
    @{ quote = "Weak people cannot choose how they die."; character = "Donquixote Doflamingo" }
    @{ quote = "I forgot how to be afraid a long time ago."; character = "Donquixote Doflamingo" }
    @{ quote = "There is no hope on this battlefield. Only carnage."; character = "Donquixote Doflamingo" }
    @{ quote = "This world is a cruel place. But the strong can make their own rules."; character = "Donquixote Doflamingo" }
    @{ quote = "We're living gods. And gods have no need to obey."; character = "Donquixote Doflamingo" }

    # --- Silvers Rayleigh ---
    @{ quote = "You have the power to shake the world. I felt it from the moment I met you."; character = "Silvers Rayleigh" }
    @{ quote = "A man who knows what he's fighting for is far more dangerous than one who simply fights."; character = "Silvers Rayleigh" }
    @{ quote = "Roger never had a devil fruit. He had spirit."; character = "Silvers Rayleigh" }
    @{ quote = "Someday someone will find the One Piece and the world will be turned upside down."; character = "Silvers Rayleigh" }
    @{ quote = "Gold Roger taught me that the world is full of things worth fighting for."; character = "Silvers Rayleigh" }
    @{ quote = "I couldn't stop that boy. Not that anyone could."; character = "Silvers Rayleigh" }

    # --- Blackbeard ---
    @{ quote = "People's dreams never die!"; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "Power isn't determined by your size, but the size of your heart and dreams!"; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "A man's dream is eternal."; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "Darkness swallows all light."; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "The age of pirates is not over. It's just begun!"; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "I am the one who will end this era and begin a new one."; character = "Marshall D. Teach (Blackbeard)" }
    @{ quote = "I have the darkness and the tremors. With these two powers, I will become the Pirate King!"; character = "Marshall D. Teach (Blackbeard)" }

    # --- Jinbe ---
    @{ quote = "Stop counting only what you have lost! What is gone, is gone!"; character = "Jinbe" }
    @{ quote = "You can't bring back what you've lost. Think about what you have now!"; character = "Jinbe" }
    @{ quote = "A man who abandons his crewmates deserves no respect."; character = "Jinbe" }
    @{ quote = "Luffy, stop crying! Look forward! Mourn the dead when it's over, now we must survive!"; character = "Jinbe" }
    @{ quote = "Blood does not make a family. Will and love do."; character = "Jinbe" }
    @{ quote = "I pledge my life to this crew. From this day forward, I sail under the Straw Hat flag."; character = "Jinbe" }
    @{ quote = "I do not fear death. I only fear dying without purpose."; character = "Jinbe" }

    # --- Dr. Hiluluk ---
    @{ quote = "When does a man die? When he is hit by a bullet? No! When he suffers a disease? No! A man dies when he is forgotten!"; character = "Dr. Hiluluk" }
    @{ quote = "A man dies when he is forgotten. But dreams never die."; character = "Dr. Hiluluk" }
    @{ quote = "Flowers are such beautiful things. They bloom even when no one is watching."; character = "Dr. Hiluluk" }
    @{ quote = "Cherry blossoms... will bloom on this snow."; character = "Dr. Hiluluk" }
    @{ quote = "Even if you're a quack doctor, you can still save someone."; character = "Dr. Hiluluk" }
    @{ quote = "I may not have any medical talent, but I believe in miracles."; character = "Dr. Hiluluk" }

    # --- Dr. Kureha ---
    @{ quote = "Don't waste my time with self-pity!"; character = "Dr. Kureha" }
    @{ quote = "I'm 139 years old and stronger than most men half my age!"; character = "Dr. Kureha" }
    @{ quote = "Quit your sniveling and become strong enough that no one can hurt you!"; character = "Dr. Kureha" }
    @{ quote = "Chopper... grow up to be a great doctor."; character = "Dr. Kureha" }

    # --- Corazon (Rosinante) ---
    @{ quote = "I am not a government dog. I'm your guardian."; character = "Corazon (Donquixote Rosinante)" }
    @{ quote = "For the first time in my life... I found a reason to keep living."; character = "Corazon (Donquixote Rosinante)" }
    @{ quote = "You don't have to carry the weight of the world alone, Law."; character = "Corazon (Donquixote Rosinante)" }
    @{ quote = "There's no such thing as a life without worth. Especially yours."; character = "Corazon (Donquixote Rosinante)" }
    @{ quote = "This is the only thing I can do for you. Live, Law. Live a full life!"; character = "Corazon (Donquixote Rosinante)" }
    @{ quote = "I'll protect you even if it costs me my life. I swear it."; character = "Corazon (Donquixote Rosinante)" }

    # --- Kaido ---
    @{ quote = "In this world, there are only two kinds of people: those who are strong, and those who die."; character = "Kaido" }
    @{ quote = "What does not kill you... was not strong enough."; character = "Kaido" }
    @{ quote = "I can't die even when I want to. That is truly my greatest misfortune."; character = "Kaido" }
    @{ quote = "Weaklings can't choose how they die."; character = "Kaido" }
    @{ quote = "Do you have what it takes to dream? Or will you fall?"; character = "Kaido" }
    @{ quote = "The only thing that can stop a pirate is another pirate."; character = "Kaido" }

    # --- Big Mom ---
    @{ quote = "Rejoice! It is a good era to be alive!"; character = "Big Mom (Charlotte Linlin)" }
    @{ quote = "You'll all become my family... whether you like it or not!"; character = "Big Mom (Charlotte Linlin)" }
    @{ quote = "Don't underestimate Mother's love."; character = "Big Mom (Charlotte Linlin)" }
    @{ quote = "My dream is to make a world where all races live together and share meals."; character = "Big Mom (Charlotte Linlin)" }
    @{ quote = "No one leaves my island alive without my permission."; character = "Big Mom (Charlotte Linlin)" }
    @{ quote = "Give me your lifespan!"; character = "Big Mom (Charlotte Linlin)" }

    # --- Katakuri ---
    @{ quote = "I won't lose. Not to anyone."; character = "Katakuri" }
    @{ quote = "I can see the future, but I couldn't see you coming."; character = "Katakuri" }
    @{ quote = "Perfection is merely being better than everyone else."; character = "Katakuri" }
    @{ quote = "The only thing that separates the strong from the weak... is determination."; character = "Katakuri" }
    @{ quote = "You're not kneeling. Get up and keep fighting. Show me what you're worth."; character = "Katakuri" }
    @{ quote = "Don't mistake kindness for weakness."; character = "Katakuri" }

    # --- Yamato ---
    @{ quote = "I won't become a samurai or a pirate. I'll be my own person!"; character = "Yamato" }
    @{ quote = "I want to be free, just like Kozuki Oden!"; character = "Yamato" }
    @{ quote = "My father can chain my body, but he can't chain my soul!"; character = "Yamato" }
    @{ quote = "Oden's journal showed me the truth of the world!"; character = "Yamato" }
    @{ quote = "I am Yamato! Son of Kaido! And I choose my own destiny!"; character = "Yamato" }
    @{ quote = "I want to see this world Oden talked about."; character = "Yamato" }

    # --- Boa Hancock ---
    @{ quote = "Love is... weight."; character = "Boa Hancock" }
    @{ quote = "I am the most beautiful woman in the world. Is that not reason enough?"; character = "Boa Hancock" }
    @{ quote = "Everything I do is out of love. Even the most terrible acts."; character = "Boa Hancock" }
    @{ quote = "Beauty is power. Anyone who says otherwise is ugly."; character = "Boa Hancock" }
    @{ quote = "I'd die before I go back to being a slave."; character = "Boa Hancock" }
    @{ quote = "I have never begged anyone for anything. But for him... I would."; character = "Boa Hancock" }

    # --- Eneru ---
    @{ quote = "I am God. And this world... is my paradise."; character = "Eneru" }
    @{ quote = "No one can surpass a god."; character = "Eneru" }
    @{ quote = "There is no such thing as miracles. There is only the will of God... and that is me."; character = "Eneru" }
    @{ quote = "The sky has no limit. And neither does my power."; character = "Eneru" }
    @{ quote = "Thunder shall be your punishment!"; character = "Eneru" }

    # --- Rob Lucci ---
    @{ quote = "You can die with your regrets."; character = "Rob Lucci" }
    @{ quote = "Strength is justice. Weakness is sin."; character = "Rob Lucci" }
    @{ quote = "Those who defy the World Government will be crushed."; character = "Rob Lucci" }
    @{ quote = "The world only has room for the strong."; character = "Rob Lucci" }

    # --- Crocodile ---
    @{ quote = "A pirate's job is not to be killed. It's to live."; character = "Crocodile" }
    @{ quote = "The weak will always be beneath the feet of the strong. That is just the way of the world."; character = "Crocodile" }
    @{ quote = "There is no such thing as hope. There is only power."; character = "Crocodile" }
    @{ quote = "Dreams can't be worth anything if they're not protected by power."; character = "Crocodile" }
    @{ quote = "Arrogance will get you killed faster than a bullet in this world."; character = "Crocodile" }

    # --- Monkey D. Garp ---
    @{ quote = "Justice without compassion is just another form of cruelty."; character = "Monkey D. Garp" }
    @{ quote = "Even if my grandson becomes a pirate... I'll still be proud of him."; character = "Monkey D. Garp" }
    @{ quote = "A fist is worth a thousand words."; character = "Monkey D. Garp" }
    @{ quote = "You fool. Don't lecture me about justice."; character = "Monkey D. Garp" }
    @{ quote = "I was trying to be a good grandfather. Clearly I failed."; character = "Monkey D. Garp" }

    # --- Monkey D. Dragon ---
    @{ quote = "The world will change. That I believe in."; character = "Monkey D. Dragon" }
    @{ quote = "Freedom is not given. It is taken."; character = "Monkey D. Dragon" }
    @{ quote = "There is a storm coming. One that will remake the world."; character = "Monkey D. Dragon" }
    @{ quote = "Those who cannot change their world will always be victims of it."; character = "Monkey D. Dragon" }

    # --- Akainu ---
    @{ quote = "Absolute Justice. That is what I believe in."; character = "Akainu (Sakazuki)" }
    @{ quote = "Anything that does not serve justice must be eliminated."; character = "Akainu (Sakazuki)" }
    @{ quote = "A soldier who hesitates on the battlefield is already dead."; character = "Akainu (Sakazuki)" }
    @{ quote = "The man who would be Pirate King... won't be getting away alive."; character = "Akainu (Sakazuki)" }

    # --- Aokiji ---
    @{ quote = "I don't agree with absolute justice. There are times you have to let people live."; character = "Aokiji (Kuzan)" }
    @{ quote = "I'm not trying to become an Admiral who just follows orders. I'm following my own justice."; character = "Aokiji (Kuzan)" }
    @{ quote = "Some things you can't stop. But you can choose how you face them."; character = "Aokiji (Kuzan)" }
    @{ quote = "The sea... is cold. People... are cold too."; character = "Aokiji (Kuzan)" }

    # --- Kizaru ---
    @{ quote = "Oh my... What a troublesome situation."; character = "Kizaru (Borsalino)" }
    @{ quote = "Light travels at 300,000 km per second. You can't run from that."; character = "Kizaru (Borsalino)" }
    @{ quote = "I have no idea what to do next. Let's see... Oh, I know. I'll just destroy everything."; character = "Kizaru (Borsalino)" }

    # --- Sengoku ---
    @{ quote = "The balance of power in this world depends on the Three Great Powers. Destroy that balance and we invite catastrophe."; character = "Sengoku" }
    @{ quote = "A father watching his son on the battlefield... that is the cruelest war."; character = "Sengoku" }
    @{ quote = "I carry the weight of this world on my shoulders. That is what it means to be a Fleet Admiral."; character = "Sengoku" }

    # --- Bartholomew Kuma ---
    @{ quote = "I will be your shield."; character = "Bartholomew Kuma" }
    @{ quote = "My last act as myself will be to protect your crew."; character = "Bartholomew Kuma" }
    @{ quote = "Pain... is relative."; character = "Bartholomew Kuma" }

    # --- Marco ---
    @{ quote = "Marco the Phoenix never falls... because every time he falls, he rises."; character = "Marco" }
    @{ quote = "I'll protect Pops' era, even if I have to do it alone."; character = "Marco" }
    @{ quote = "The Whitebeard Pirates don't abandon their own. That's our code."; character = "Marco" }
    @{ quote = "Every pirate who sailed with Whitebeard carries a piece of him in their heart."; character = "Marco" }

    # --- Kyros ---
    @{ quote = "I lived as a toy for 10 years. But my heart never forgot who I was."; character = "Kyros" }
    @{ quote = "I am not a hero. I'm just a father."; character = "Kyros" }
    @{ quote = "Rebecca... I am your father. And I'll protect you with everything I have."; character = "Kyros" }
    @{ quote = "Even if the world forgot about me, I never forgot about her."; character = "Kyros" }

    # --- Pedro ---
    @{ quote = "My life was given for this moment. Let it not be wasted."; character = "Pedro" }
    @{ quote = "This is my time. Let this flash illuminate the future!"; character = "Pedro" }

    # --- Coby ---
    @{ quote = "I want to become an admiral. Not to be strong, but to protect people!"; character = "Coby" }
    @{ quote = "Give up? I have never given up on anything in my entire life!"; character = "Coby" }
    @{ quote = "The path of a Marine is not just about following orders. It's about protecting lives."; character = "Coby" }
    @{ quote = "I don't care about being called a hero. I just want to save people."; character = "Coby" }

    # --- Smoker ---
    @{ quote = "Justice has to mean something beyond just winning."; character = "Smoker" }
    @{ quote = "I won't let pirates escape on my watch."; character = "Smoker" }

    # --- Tashigi ---
    @{ quote = "Swords should not be in the hands of those who don't know their worth."; character = "Tashigi" }
    @{ quote = "I'm not crying because I lost. I'm crying because I was too weak to protect what I cared about."; character = "Tashigi" }
    @{ quote = "I'll become stronger. Strong enough that I'll never have to see that look again."; character = "Tashigi" }

    # --- Princess Vivi ---
    @{ quote = "I love this country! That's why I can't watch it be destroyed!"; character = "Princess Vivi" }
    @{ quote = "Stop fighting! Please! Millions of lives are at stake!"; character = "Princess Vivi" }
    @{ quote = "A country's greatest treasure isn't gold or ships. It's the people."; character = "Princess Vivi" }
    @{ quote = "Everyone... thank you. You were my greatest treasure."; character = "Princess Vivi" }

    # --- Carrot ---
    @{ quote = "Pedro sacrificed himself for us. We cannot let that be in vain!"; character = "Carrot" }

    # --- Corazon / other ---
    @{ quote = "Stop counting only what you have lost. Think about what you still have."; character = "Jinbe" }
)

$pick = $quotes | Get-Random
$quoteText     = $pick.quote
$characterName = $pick.character

$boxWidth   = 62
$innerWidth = $boxWidth - 4

function Wrap-Text {
    param([string]$text, [int]$width)
    $words   = $text -split ' '
    $lines   = @()
    $current = ''
    foreach ($word in $words) {
        if (($current.Length + $word.Length + 1) -le $width) {
            if ($current -eq '') { $current = $word }
            else { $current += ' ' + $word }
        } else {
            if ($current -ne '') { $lines += $current }
            $current = $word
        }
    }
    if ($current -ne '') { $lines += $current }
    return $lines
}

$border    = [string][char]0x2550
$tl        = [string][char]0x2554
$tr        = [string][char]0x2557
$bl        = [string][char]0x255A
$br        = [string][char]0x255D
$side      = [string][char]0x2551
$borderRow = $border * $boxWidth
$emptyLine = '  ' + $side + (' ' * $boxWidth) + $side

Write-Host ''
Write-Host ('  ' + $tl + $borderRow + $tr) -ForegroundColor Red
Write-Host $emptyLine -ForegroundColor Red

$wrappedLines = Wrap-Text -text $quoteText -width $innerWidth
foreach ($line in $wrappedLines) {
    $pad = $innerWidth - $line.Length
    Write-Host ('  ' + $side) -NoNewline -ForegroundColor Red
    Write-Host ('  ' + $line + (' ' * $pad) + '  ') -NoNewline -ForegroundColor White
    Write-Host $side -ForegroundColor Red
}

Write-Host $emptyLine -ForegroundColor Red

$charLine = '-- ' + $characterName + ' '
$charPad  = $boxWidth - $charLine.Length
Write-Host ('  ' + $side) -NoNewline -ForegroundColor Red
Write-Host ((' ' * $charPad) + $charLine) -NoNewline -ForegroundColor Yellow
Write-Host $side -ForegroundColor Red

Write-Host $emptyLine -ForegroundColor Red
Write-Host ('  ' + $bl + $borderRow + $br) -ForegroundColor Red

$footer    = '~ ONE PIECE ~'
$footerPad = [math]::Floor(($boxWidth - $footer.Length) / 2) + 2
Write-Host ((' ' * $footerPad) + $footer) -ForegroundColor Cyan
Write-Host ''
